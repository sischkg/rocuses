# -*- coding: utf-8 -*-

require 'rocuses/config/managerconfig'
require 'rocuses/config/targetsconfig'
require 'rocuses/datasource'
require 'rocuses/graphtemplate'
require 'rocuses/resource'
require 'pp'
require 'net/http'
require 'rrdtool'

module Rocuses
  module Manager

    module_function

    def fetch_resource()
      manager_config = Rocuses::Config::ManagerConfig.new
      File.open( '/etc/rocuses/managerconfig.xml' ) { |xml|
        manager_config.load( xml )
      }

      RRDTool::set_parameters( :rrdtool_path   => manager_config.rrdtool_path,
                               :rrd_store_path => manager_config.rra_directory )

      targets_config = Rocuses::Config::TargetsConfig.new
      File.open( '/etc/rocuses/targetsconfig.xml' ) { |xml|
        targets_config.load( xml )
      }
      pp targets_config

      targets_config.targets.each { |target|
        begin
          data = Net::HTTP.get( target.hostname, '/resource', target.port )
          resource = Rocuses::Resource.deserialize( data )

          cpus = Array.new
          resource.cpus.each { |cpu|
            cpu_usage = Rocuses::DataSource::CPU.new( target.name, cpu.name )
            cpu_usage.update( manager_config, resource )
            cpus.push( cpu_usage )
          }
          cpu_average = Rocuses::DataSource::CPUAverage.new( target.name )
          cpu_average.update( manager_config, resource )          

          graph_template = Rocuses::GraphTemplate::CPU.new( cpus )
          image = graph_template.draw( manager_config, Time.now - 86400, Time.now )

          File.open( '/tmp/localhost_cpu.png', File::WRONLY | File::CREAT || File::TRUNCATE ) { |output|
            output.print( image )
          }

          graph_template = Rocuses::GraphTemplate::CPUAverage.new( cpu_average )
          image = graph_template.draw( manager_config, Time.now - 86400, Time.now )

          File.open( '/tmp/localhost_cpu_average.png', File::WRONLY | File::CREAT || File::TRUNCATE ) { |output|
            output.print( image )
          }

        rescue => e
          p e
          p e.backtrace
        end
      }
    end
  end
end

