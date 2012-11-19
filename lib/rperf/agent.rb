# -*- coding: utf-8 -*-

require 'webrick'
require 'rperf/agent/linux'
require 'rperf/agent/noos'

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

      return resource
    end
  end

  class HTTPServer
    HTTP_DOCUMENT_ROOT = "/usr/local/share/rperf/www"
    HTTP_SERVER_PORT   = 20080

    def initialize
      @agent = RPerf::Agent.new
    end

    def start()
      @http_server = WEBrick::HTTPServer.new( :DocumentRoot => HTTP_DOCUMENT_ROOT,
                                              :Port         => HTTP_SERVER_PORT )
      @http_server.mount_proc('/resource' ) { |request,response|
        resource = @agent.get_status()
        response.content_type = 'text/plain'
        response.body = resource.serialize
      }

      trap("INT"){ @http_server.shutdown }
      @http_server.start()
    end
  end
end
