# -*- coding: utf-8 -*-

require 'pp'
require 'etc'
require 'rubygems'
require 'log4r'
require 'log4r/outputter/datefileoutputter'
require 'log4r/configurator'
require 'webrick'
require 'rocuses/utils'
require 'rocuses/agentparameters'
require 'rocuses/agent/linux'
require 'rocuses/agent/noos'
require 'rocuses/agent/bind'
require 'rocuses/agent/nobind'
require 'rocuses/agent/openldap'
require 'rocuses/agent/noopenldap'
require 'rocuses/agent/usbrh'
require 'rocuses/agent/notemperature'
require 'rocuses/config/agentconfig'

module Log4r
  class Logger
    def <<( str )
      self.info( str.chomp )
    end
  end
end

module Rocuses
  class Agent
    OS_AGENTS          = [ Rocuses::Agent::Linux, Rocuses::Agent::NoOS ]
    BIND_AGENTS        = [ Rocuses::Agent::Bind, Rocuses::Agent::NoBind ]
    OPENLDAP_AGENTS    = [ Rocuses::Agent::OpenLDAP, Rocuses::Agent::NoOpenLDAP ]
    TEMPERATURE_AGENTS = [ Rocuses::Agent::Usbrh, Rocuses::Agent::NoTemperature ]
    LOG4R_CONFIG = '/etc/rocuses/log4r.xml'

    include Log4r

    def initialize( agentconfig )
      @agentconfig = agentconfig

      @error_logger = Logger.new( 'rocuses::agent' )
      @error_logger.outputters  = DateFileOutputter.new( 'error_log',
                                                         {
                                                           :dirname      => Rocuses::AgentParameters::LOG_DIRECTORY,
                                                           :date_pattern => 'error_log.%Y-%m-%d',
                                                           :level        => INFO,
                                                         } )

      OS_AGENTS.each { |os_agent|
        if os_agent.match_environment?( @agentconfig )
          @os_agent = os_agent.new( @agentconfig )
          break
        end
      }

      BIND_AGENTS.each { |bind_agent|
        if bind_info = bind_agent.match_environment?( @agentconfig )
          @bind_agent = bind_agent.new( @agentconfig, bind_info )
          break
        end
      }

      OPENLDAP_AGENTS.each { |openldap_agent|
        if openldap_agent.match_environment?( @agentconfig )
          @openldap_agent = openldap_agent.new( @agentconfig )
          break
        end
      }

      TEMPERATURE_AGENTS.each { |temperature_agent|
        if path = temperature_agent.match_environment?( @agentconfig )
          @temperature_agent = temperature_agent.new( @agentconfig, path )
          break
        end
      }

    end

    def get_resource_status_all( resource )
      @os_agent.get_cpu_average( resource )
      @os_agent.get_cpus( resource )
      @os_agent.get_virtual_memory_status( resource )
      @os_agent.get_page_io_status( resource )
      @os_agent.get_network_interface_status( resource )
      @os_agent.get_processes( resource )
      @os_agent.get_filesystem_status( resource )
      @os_agent.get_load_average( resource )
      @os_agent.get_disk_ios( resource )
      @bind_agent.get_bind_statistics( resource )
      @openldap_agent.get_openldap_statistics( resource )
      @temperature_agent.get_temperature( resource )
    end

    def get_resource_status( type, resource )
      begin
        @os_agent.get_resource( type, resource )
        @bind_agent.get_resource( type, resource )
        @openldap_agent.get_resource( type, resource )
        @temperature_agent.get_resource( type, resource )
      rescue ArgumentError => e
        @error_logger.info( "resource type #{ type } is not supported" )
      end
    end
    
  end

  class HTTPServer
    HTTP_DOCUMENT_ROOT      = "/usr/local/share/rocuses/www"
    PID_FILE                = "/var/run/rocusagent.pid"
    RESOURCE_TYPE_DELIMITOR = %q{,}

    include Log4r
    include Rocuses

    def initialize( args )
      args = Utils::check_args( args, { :agentconfig => :req, :daemonize => :op, }, { :daemonize => false } )
      @agentconfig = args[:agentconfig]
      @daemonize   = args[:daemonize]
    end

    # エージェントのサービスを開始数する。
    def start()
      setup_directory()
      create_logger()

      @agent = Rocuses::Agent.new( @agentconfig )

      @http_server = WEBrick::HTTPServer.new( :DocumentRoot => HTTP_DOCUMENT_ROOT,
                                              :Port         => @agentconfig.bind_port,
                                              :BindAddress  => @agentconfig.bind_address,
                                              :ServerType   => WEBrick::SimpleServer,
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
        path_info = request.path_info
        path_info.gsub!( %r{/}, %q{} )
        @error_logger.info( "request #{ path_info } from #{ request.peeraddr[2] } " )
        types = path_info.split( RESOURCE_TYPE_DELIMITOR )

        resource = Resource.new
        types.each { |type|
          @agent.get_resource_status( type, resource )
        }
        response.body = resource.serialize
      }

      ENV["LANG"]   = "C"
      ENV["LC_ALL"] = "C"

      trap("INT"){ @http_server.shutdown }
      @error_logger.info( "starting httpd" )
      if @daemonize
        daemonize_agent()
      end

      # set_eid()
      @http_server.start()
    end

    private

    # HTTPリクエストの接続元IPアドレスを参照し、正しい接続元であるかを確かめる。
    # ManagerのIPアドレスを登録していない場合（@agentconfig.managers == [] )は、任意のIPアドレスからの接続を許可する。
    # request:: リクエストのHTTPRequestインスタンス
    # RETURN:: true:接続元はManagerである / false: 接続元はManagerではない
    def validate_manager( request )
      msg = sprintf( "request: %s, magager %s", request.peeraddr.to_s, @agentconfig.managers.join( "," ) )
      @error_logger.info( msg )

      if @agentconfig.managers.size == 0
        return true
      end

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

    # pathに対するHTTPリクエストの処理内容を定義する。
    # path:: HTTPリクエストのPATH
    # block:: requestに対する処理 
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
          if ! @daemonize
            STDERR.printf( "%s\n", e )
            STDERR.printf( "%s\n", e.backtrace )
          end
          raise e
        end
      }
    end

    # プロセスをデーモン化し、そのデーモンのプロセスのPIDをPID_FILEへ保存する。
    def daemonize_agent()
      if Process.respond_to?( :daemon )  # Ruby 1.9
        Process.daemon
      else                            # Ruby 1.8
        WEBrick::Daemon.start
      end     

      begin 
        File.open( PID_FILE, 'w' ) { |pidfile|
          pidfile.printf( "%d\n", Process.pid )
        }
      rescue => e
        @error_logger.error( "cannot write pid file: #{ e }:#{ e.backtrace }" )
        exit
      end
    end

    # プロセスのEUID/EGIDを変更する。
    def set_eid()
      gid = uid = 0
      begin
        gid = Etc.getgrnam( @agentconfig.group ).gid
        Process::Sys.setegid( gid )
      rescue ArgumentError => e
        raise "cannot find group #{ @agentconfig.group }"
      rescue => e
        raise "cannot set egid( #{ e.to_s } )"
      end

      begin
        uid = Etc.getpwnam( @agentconfig.user ).uid
        Process::Sys.seteuid( uid )
      rescue ArgumentError => e
        raise "cannot find user #{ @agentconfig.user }"
      rescue => e
        raise "cannot set euid( #{ e.to_s } )"
      end
    end

    # エージェントの動作に必要なディレクトリを作成する。
    def setup_directory
      begin
        if ! File.directory?( Rocuses::AgentParameters::LOG_DIRECTORY )
          FileUtils.mkdir( Rocuses::AgentParameters::LOG_DIRECTORY )
        end
        FileUtils.chown( @agentconfig.user,
                         @agentconfig.group,
                         [
                          Rocuses::AgentParameters::LOG_DIRECTORY,
                         ] )
      rescue => e
        raise "cannot setup a directory for rocusagent( #{ e.to_s } )."
      end
    end

    #
    def create_logger
      @access_logger = Logger.new( 'rocus::agent::httpd::access_log' )
      @error_logger  = Logger.new( 'rocus::agent::httpd::error_log' )

      @access_logger.outputters = DateFileOutputter.new( 'httpd_access_log',
                                                         {
                                                           :dirname      => Rocuses::AgentParameters::LOG_DIRECTORY,
                                                           :date_pattern => 'httpd_access_log',
                                                           :level        => INFO,
                                                         } )
      @error_logger.outputters = DateFileOutputter.new( 'httpd_error_log',
                                                        {
                                                          :dirname      => Rocuses::AgentParameters::LOG_DIRECTORY,
                                                          :date_pattern => 'httpd_error_log',
                                                          :level        => INFO,
                                                        } )

    end
  end
end
