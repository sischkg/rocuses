# -*- coding: utf-8 -*-

require 'pp'
require 'webrick'
require 'args'
require 'rperf/agent/linux'
require 'rperf/agent/noos'
require 'rperf/config/agentconfig'

module RPerf
  class Agent
    OS_AGENTS = [ RPerf::Agent::Linux, RPerf::Agent::NoOS ]

    def initialize
      OS_AGENTS.each { |os_agent|
        if os_agent.match_environment?
          @os_agent = os_agent.new
          return
        end
      }
    end

    def get_status
      resource = RPerf::Resource.new

      @os_agent.get_cpu_status( resource )
      @os_agent.get_virtual_memory_status( resource )
      @os_agent.get_network_interface_status( resource )
      @os_agent.get_processes( resource )
      @os_agent.get_filesystem_status( resource )
      @os_agent.get_load_average( resource )
      @os_agent.get_disk_ios( resource )
      return resource
    end
  end

  class HTTPServer
    HTTP_DOCUMENT_ROOT = "/usr/local/share/rperf/www"
    HTTP_SERVER_PORT   = 20080
    PID_FILE           = "/var/run/rperfagent.pid"

    def initialize( args )
      pp args
      args = Args::check_args( args, { :config => :req, :daemonize => :op, }, { :daemonize => false } )
      @agent = RPerf::Agent.new
      @agentconfig = args[:agentconfig]
      @daemonize = args[:daemonize] ? WEBrick::Daemon : WEBrick::SimpleServer
      @logger = WEBrick::Log.new
    end

    def start()
      @http_server = WEBrick::HTTPServer.new( :DocumentRoot => HTTP_DOCUMENT_ROOT,
                                              :Port         => HTTP_SERVER_PORT,
                                              :ServerType   => @daemonize,
                                              :DoNotReverseLookup => true, )
      @http_server.mount_proc('/resource' ) { |request,response|
        if ! validate_manager( request )
          response_forbiden( response )
        else
          response.content_type = 'text/plain'
          resource = @agent.get_status()
          response.body = resource.serialize
        end
      }

      ENV["LANG"] = "C"
      ENV["LC_ALL"] = "C"

      trap("INT"){ @http_server.shutdown }
      @http_server.start()
    end

    private

    def validate_manager( request )
      @logger << sprintf( "request: %s, magager %s", request.peeraddr.to_s, @agentconfig.managers.join( "," ) )
      is_valid_manager = false
      @agentconfig.managers.each { |manager|
        @logger << manager
        if request.peeraddr[2] == manager || request.peeraddr[3] == manager
          is_valid_manager = true
        end
      }
      return is_valid_manager
    end

    def response_forbiden( response )
      response.status = 403
      response.content_type = 'text/plain'
      response.body = 'forbiden'
    end


  end
end
