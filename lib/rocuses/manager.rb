# -*- coding: utf-8 -*-

require 'pp'
require 'net/http'
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
  module Manager

    module_function

    def fetch_resource()
      manager_config = Rocuses::Config::ManagerConfig.new
      File.open( Rocuses::ManagerParameters::MANAGER_CONFIG_FILENAME ) { |xml|
        manager_config.load( xml )
      }

      RRDTool::set_parameters( :rrdtool_path   => manager_config.rrdtool_path,
                               :rrd_store_path => manager_config.rra_directory )

      targets_config = Rocuses::Config::TargetsConfig.new
      File.open( Rocuses::ManagerParameters::TARGETS_CONFIG_FILENAME ) { |xml|
        targets_config.load( xml )
      }

      graphs = Array.new

      targets_config.targets.each { |target|
        begin
          unix_server = Rocuses::Device::UnixServer.new( target )

          data = Rocuses::Fetch.new.fetch( target )
          resource = Rocuses::Resource.deserialize( data )
          unix_server.update( manager_config, resource )

          graphs = Array.new
          unix_server.make_graph_templates().each { |graph_template|
            graph = graph_template.make_graph
            Rocuses::ManagerParameters::GRAPH_TIME_PERIOD_OF.each { |period_suffix,period|
              begin_time = Time.now - period
              end_time   = Time.now
              image = graph.draw( :begin_time => begin_time,
                                  :end_time   => end_time,
                                  :width      => manager_config.image_width,
                                  :height     => manager_config.image_height )

              graph_info = Graph.new( :image      => image,
                                      :name       => sprintf( "%s %s %s",
                                                              target.name,
                                                              graph_template.name,
                                                              period_suffix ),
                                      :filename   => sprintf( "%s/%s_%s_%s.png",
                                                              manager_config.graph_directory,
                                                              target.name,
                                                              graph_template.name,
                                                              period_suffix ),
                                      :begin_time => begin_time,
                                      :end_time   => end_time )

              graphs << graph_info
            }
          }

        rescue => e
          p e
          p e.backtrace
        end
      }

      graphs.each { |graph_info|
        begin
          File.open( graph_info.filename, File::WRONLY | File::CREAT || File::TRUNCATE ) { |output|
            output.print( graph_info.image )
          }                                                                                                                                                 
        rescue => e
          p e
          p e.backtrace
        end
      }

    end
  end
end

