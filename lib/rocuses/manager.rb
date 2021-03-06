# -*- coding: utf-8 -*-

require 'pp'
require 'net/http'
require 'rubygems'
require 'log4r'
require 'log4r/outputter/datefileoutputter'
require 'log4r/configurator'
require 'rocuses/rrdtool'
require 'rocuses/config/managerconfig'
require 'rocuses/config/targetsconfig'
require 'rocuses/datasource'
require 'rocuses/graphtemplate'
require 'rocuses/resource'
require 'rocuses/fetch'
require 'rocuses/graph'
require 'rocuses/device'
require 'rocuses/managerparameters'

module Rocuses
  class Manager
    include Rocuses
    include Log4r

    LOG_DIRECTORY      = '/var/log/rocuses'

    attr_reader :graph_template_manager

    def initialize
      @logger = Logger.new( 'rocuses::manager' )
      @devices = Array.new
      @graph_template_manager = GraphTemplate::Manager.new

      formatter = Log4r::PatternFormatter.new( :pattern     => "%d %C %l: %M",
                                               :date_format => "%Y/%m/%d %H:%M:%S" )
      @logger.outputters  = DateFileOutputter.new( 'error_log',
                                                   {
                                                     :dirname      => LOG_DIRECTORY,
                                                     :date_pattern => 'error_log.%Y-%m-%d',
                                                     :formatter    => formatter,
                                                   } )
      @manager_config = load_manager_config()
      @targets_config = load_targets_config()

      RRDTool::set_parameters( :rrdtool_path   => @manager_config.rrdtool_path,
                               :rrd_store_path => @manager_config.rra_directory )

    end

    def fetch_resource()

      RRDTool::set_parameters( :rrdtool_path   => @manager_config.rrdtool_path,
                               :rrd_store_path => @manager_config.rra_directory )

      @targets_config.targets.each { |target|
        if target.disable
          next
        end

        @logger.info( sprintf( "fetching from %s(%s)", target.name, target.hostname ) )
        begin
          unix_server = Device::UnixServer.new( target )

          data = Fetch.new.fetch( target )
          resource = Resource.deserialize( data )
          errors = unix_server.update( @manager_config, resource )
          errors.each { |e|
              @logger.error( sprintf( "update error %s:%s: %s", target.name, target.hostname, e.to_s ) )
          }

          @devices << unix_server

          unix_server.make_graph_templates.each { |graph_template|
            begin
              @graph_template_manager.add_graph_template( graph_template )
            rescue => e
              @logger.error( sprintf( "make graph_template error %s:%s: %s", target.name, target.hostname, e.to_s ) )
              @logger.error( sprintf( "backtrace from %s:%s: %s", target.name, target.hostname, e.backtrace ) )
            end
          }

        rescue => e
          @logger.error( sprintf( "fetching error from %s(%s): %s", target.name, target.hostname, e.to_s ) )
          @logger.error( sprintf( "backtrace from %s(%s): %s", target.name, target.hostname, e.backtrace ) )
        end
      }

      save_graph_templates()
    end

    def draw_graph
      manager_config = load_manager_config()

      graphs = Array.new

      @graph_template_manager.each { |graph_template|
        begin
          graph = graph_template.make_graph

          ManagerParameters::GRAPH_TIME_PERIOD_OF.each { |period_suffix,period|
            begin
              end_time   = Time.now
              begin_time = end_time - period

              image = graph.make_image( :begin_time => begin_time,
                                        :end_time   => end_time,
                                        :width      => @manager_config.image_width,
                                        :height     => @manager_config.image_height )

              graph_info = Graph.new( :image      => image,
                                      :name       => sprintf( "%s %s %s",
                                                              graph_template.nodenames.join( %q{,} ),
                                                              graph_template.name,
                                                              period_suffix ),
                                      :filename   => sprintf( "%s/%s_%s_%s.png",
                                                              @manager_config.graph_directory,
                                                              graph_template.nodenames.join( %q{_} ),
                                                              graph_template.filename,
                                                              period_suffix ),
                                      :begin_time => begin_time,
                                      :end_time   => end_time )
              graphs << graph_info
            rescue => e
              @logger.error( sprintf( "saving graph_info error from %s:%s: %s",
                                      graph_info.nodenames.join( "," ),
                                      graph_template.name,
                                      e.to_s ) )
              @logger.error( sprintf( "backtrace from %s:%s(%s): %s",
                                      graph_template.nodenames.join( "," ),
                                      graph_template.name,
                                      e.backtrace ) )
            end
          }

          save_graph_templates()
        rescue => e
          @logger.error( sprintf( "saving graph_template error from %s:%s: %s",
                                  graph_template.nodenames.join( "," ),
                                  graph_template.name,
                                  e.to_s ) )
          @logger.error( sprintf( "backtrace from %s:%s: %s",
                                  graph_template.nodenames.join( "," ),
                                  graph_template.name,
                                  e.backtrace ) )
        end
      }

      graphs.each { |graph_info|
        begin
          File.open( graph_info.filename, File::WRONLY | File::CREAT || File::TRUNCATE ) { |output|
            output.print( graph_info.image )
          }                           
        rescue => e
          @logger.error( e.to_s )
          @logger.error( e.backtrace )
        end
      }

    end

    def load_graph_templates
      File.open( ManagerParameters::GRAPH_TEMPLATES_FILENAME, File::RDONLY ) { |input|
        input.flock( File::LOCK_SH )
        @graph_template_manager = YAML.load( input )
      }
    end

    private

    def load_config( config_class, filename )
      config = config_class.new
      File.open( filename ) { |xml|
        config.load( xml )
      }
      return config
    end

    def load_manager_config()
      return load_config( Config::ManagerConfig,
                          ManagerParameters::MANAGER_CONFIG_FILENAME )
    end

    def load_targets_config()
      return load_config( Config::TargetsConfig,
                          ManagerParameters::TARGETS_CONFIG_FILENAME )

    end

    def save_graph_templates
      File.open( ManagerParameters::GRAPH_TEMPLATES_FILENAME, File::WRONLY | File::CREAT | File::TRUNC ) { |output|
        output.flock( File::LOCK_EX )
        YAML.dump( @graph_template_manager, output )
      }
    end
  end
end


