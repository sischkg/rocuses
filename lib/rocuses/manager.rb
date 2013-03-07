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
    include Log4r
    LOG_DIRECTORY      = '/var/log/rocuses'

    class GraphTemplateManager
      def initialize
        @graph_templates_of = Hash.new { |hash, key|
          hash[key] = Hash.new
        }
      end

      def add_graph_template( nodename, graph_template )
        @graph_templates_of[nodename][graph_template.id] = graph_template
      end

      def get_graph_template( nodename, id )
        if @graph_templates_of.key?( nodename ) && @graph_templates_of[nodename].key?( id )
          return @graph_templates_of[nodename][id]
        end
        raise ArgumentError.new( "#{ id } of #{ nodename } dose not exist." ) 
      end

      def get_graph_templates_by_node( nodename )
        if @graph_templates_of.key?( nodename )
          return @graph_templates_of[nodename]
        end
        raise ArgumentError.new( "#{ nodename } dose not exist." ) 
      end

      def each()
        if block_given?
          @graph_templates_of.each { |nodename, graph_template_of_node|
            graph_template_of_node.each { |id, graph_template|
              yield( nodename, graph_template )
            }
          }
        else
          graph_templates = Array.new
          @graph_templates_of.values.each { |nodename, graph_template_of_node|
            graph_template_of_node.each { |id, graph_template|
              graph_templates << graph_template
            }
          }
          return graph_templates
        end
      end
    end


    attr_reader :graph_template_manager

    def initialize
      @logger = Logger.new( 'rocuses::manager' )
      @devices = Array.new
      @graph_template_manager = GraphTemplateManager.new

      @logger.outputters  = DateFileOutputter.new( 'error_log',
                                                   {
                                                     :dirname      => LOG_DIRECTORY,
                                                     :date_pattern => 'error_log.%Y-%m-%d',
                                                   } )
    end

    def fetch_resource()
      manager_config = load_manager_config()
      targets_config = load_targets_config()

      RRDTool::set_parameters( :rrdtool_path   => manager_config.rrdtool_path,
                               :rrd_store_path => manager_config.rra_directory )

      targets_config.targets.each { |target|
        begin
          unix_server = Device::UnixServer.new( target )

          data = Fetch.new.fetch( target )
          resource = Resource.deserialize( data )
          unix_server.update( manager_config, resource )

          @devices << unix_server

          unix_server.make_graph_templates().each { |graph_template|
            @graph_template_manager.add_graph_template( target.name, graph_template )
          }
        rescue => e
          @logger.error( e.to_s )
          @logger.error( e.backtrace )
        end
      }

      def draw_graph
        manager_config = load_manager_config()

        graphs = Array.new

        @graph_template_manager.each { |nodename, graph_template|
          begin
            graph = graph_template.make_graph

            ManagerParameters::GRAPH_TIME_PERIOD_OF.each { |period_suffix,period|
              end_time   = Time.now
              begin_time = end_time - period

              image = graph.make_image( :begin_time => begin_time,
                                        :end_time   => end_time,
                                        :width      => manager_config.image_width,
                                        :height     => manager_config.image_height )

              graph_info = Graph.new( :image      => image,
                                      :name       => sprintf( "%s %s %s",
                                                              nodename,
                                                              graph_template.id,
                                                              period_suffix ),
                                      :filename   => sprintf( "%s/%s_%s_%s.png",
                                                              manager_config.graph_directory,
                                                              nodename,
                                                              graph_template.filename,
                                                              period_suffix ),
                                      :begin_time => begin_time,
                                      :end_time   => end_time )
              graphs << graph_info
            }
          rescue => e
            @logger.error( e.to_s )
            @logger.error( e.backtrace )
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
    end

    def save
      File.open( ManagerParameters::SERIALIZE_DEVICES_FILENAME, 
                 IO::WRONLY | IO::CREAT | IO::TRUNC ) { |output|
        output.flock( IO::LOCK_EX )
        output.print( YAML.dump( @devices ) )
      }
      File.open( ManagerParameters::SERIALIZE_GRAPH_TEMPLATES_FILENAME, 
                 IO::WRONLY | IO::CREAT | IO::TRUNC ) { |output|
        output.flock( IO::LOCK_EX )
        output.print( YAML.dump( @graph_template_manager ) )
      }
    end

    def load
      File.open( ManagerParameters::SERIALIZE_DEVICES_FILENAME,
                 IO::RDONLY ) { |input|
        input.flock( IO::LOCK_SH )
        @devices = YAML.load( input )
      }
      File.open( ManagerParameters::SERIALIZE_GRAPH_TEMPLATES_FILENAME,
                 IO::RDONLY ) { |input|
        input.flock( IO::LOCK_SH )
        @graph_template_manager = YAML.load( input )
      }
    end

    def devices
      if block_given?
        @devices.each { |device|
          yield( device )
        }
      else
        @devices
      end
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
  end
end

