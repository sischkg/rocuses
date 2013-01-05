# -*- coding: utf-8 -*-

require 'pp'
require 'rubygems'
require 'log4r'
require 'log4r/outputter/datefileoutputter'
require 'log4r/configurator'
require 'webrick'
require 'args'
require 'rperf/agent/linux'
require 'rperf/agent/noos'
require 'rperf/config/agentconfig'

module Log4r
  class Logger
    def <<( str )
      self.info( str.chomp )
    end
  end
end

module RPerf
  LOG_DIRECTORY      = '/var/log/rperf'

  class Agent
    OS_AGENTS = [ RPerf::Agent::Linux, RPerf::Agent::NoOS ]
    LOG4R_CONFIG = '/etc/rperf/log4r.xml'

    include Log4r

    def initialize
      @logger = Logger.new( 'rperf::agent' )
      @logger.outputters  = DateFileOutputter.new( 'error_log',  { :dirname => LOG_DIRECTORY, :lavel => INFO } )

      OS_AGENTS.each { |os_agent|
        if os_agent.match_environment?
          @os_agent = os_agent.new
          @logger.info( "Agent #{ @os_agent.name } is selected" )
          return
        end
      }
    end

    def get_resource_status_all( resource )
      @os_agent.get_cpu_average( resource )
      @os_agent.get_cpus( resource )
      @os_agent.get_virtual_memory_status( resource )
      @os_agent.get_network_interface_status( resource )
      @os_agent.get_processes( resource )
      @os_agent.get_filesystem_status( resource )
      @os_agent.get_load_average( resource )
      @os_agent.get_disk_ios( resource )
    end

    def get_resource_status( type, resource )
      return @os_agent.get_resource( type, resource )
    end
    
  end

  class HTTPServer
    HTTP_DOCUMENT_ROOT = "/usr/local/share/rperf/www"
    PID_FILE           = "/var/run/rperfagent.pid"

    include Log4r

    def initialize( args )
      args = Args::check_args( args, { :agentconfig => :req, :daemonize => :op, }, { :daemonize => false } )
      @agent         = RPerf::Agent.new
      @agentconfig   = args[:agentconfig]
      @daemonize     = args[:daemonize] ? WEBrick::Daemon : WEBrick::SimpleServer
      @error_logger  = Logger.new( 'rperf::agent::httpd::error_log' )
      @access_logger = Logger.new( 'rperf::agent::httpd::access_log' )

      @access_logger.outputters = DateFileOutputter.new( 'access_log', { :dirname => LOG_DIRECTORY, :lavel => INFO } )
      @error_logger.outputters  = DateFileOutputter.new( 'error_log',  { :dirname => LOG_DIRECTORY, :lavel => INFO } )
    end

    def start()
      @http_server = WEBrick::HTTPServer.new( :DocumentRoot => HTTP_DOCUMENT_ROOT,
                                              :Port         => @agentconfig.bind_port,
                                              :BindAddress  => @agentconfig.bind_address,
                                              :ServerType   => @daemonize,
                                              :Logger       => @error_logger,
                                              :AccessLog    => [ [ @access_logger, WEBrick::AccessLog::COMMON_LOG_FORMAT ] ],
                                              :DoNotReverseLookup => true )


      mount( '/resource' ) { |request,response|
        @error_logger.info( "request all from #{ request.peeraddr[2] } " )

        resource = Resource.new
        @agent.get_resource_status_all( resource )
        response.body = resource.serialize
      }
      
      mount('/type' ) { |request,response|
        type = request.path_info
        type.gsub!( %r{/}, %q{} )
        @error_logger.info( "request #{ type } from #{ request.peeraddr[2] } " )

        resource = Resource.new
        @agent.get_resource_status( type, resource )
        response.body = resource.serialize
      }

      ENV["LANG"]   = "C"
      ENV["LC_ALL"] = "C"

      trap("INT"){ @http_server.shutdown }
      @error_logger.info( "starting httpd" )
      @http_server.start()
    end

    private

    def validate_manager( request )
      msg = sprintf( "request: %s, magager %s", request.peeraddr.to_s, @agentconfig.managers.join( "," ) )
      @error_logger.info( msg )
      is_valid_manager = false
      @agentconfig.managers.each { |manager|
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

    def mount( path )
      @http_server.mount_proc( path ) { |request,response|
        begin 
          if ! validate_manager( request )
            response_forbiden( response )
          else
            response.content_type = 'text/plain'

            yield( request, response )
          end
        rescue => e
          @error_logger.error( "caught expection: #{ e }:#{ e.backtrace }" )
          STDERR.printf( "%s\n", e )
          STDERR.printf( "%s\n", e.backtrace )
          raise e
        end
      }
    end
  end
end
