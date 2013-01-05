# -*- coding: utf-8 -*-

require 'rperf/config/managerconfig'
require 'rperf/config/targetsconfig'
require 'rperf/datasource'
require 'rperf/graphtemplate'
require 'rperf/resource'
require 'pp'
require 'net/http'
require 'rrdtool'

module RPerf
  module Manager

    module_function

    def fetch_resource()
      manager_config = RPerf::Config::ManagerConfig.new
      File.open( '/etc/rperf/managerconfig.xml' ) { |xml|
        manager_config.load( xml )
      }

      RRDTool::set_parameters( :rrdtool_path   => manager_config.rrdtool_path,
                               :rrd_store_path => manager_config.rra_directory )

      targets_config = RPerf::Config::TargetsConfig.new
      File.open( '/etc/rperf/targetsconfig.xml' ) { |xml|
        targets_config.load( xml )
      }
      pp targets_config

      targets_config.targets.each { |target|
        begin
          data = Net::HTTP.get( target.hostname, '/resource', target.port )
          resource = RPerf::Resource.deserialize( data )

          cpus = Array.new
          resource.cpus.each { |cpu|
            cpu_usage = RPerf::DataSource::CPU.new( target.name, cpu.name )
            cpu_usage.update( manager_config, resource )
            cpus.push( cpu_usage )
          }
          cpu_average = RPerf::DataSource::CPUAverage.new( target.name )
          cpu_average.update( manager_config, resource )          

          graph_template = RPerf::GraphTemplate::CPU.new( cpus )
          image = graph_template.draw( manager_config, Time.now - 86400, Time.now )

          File.open( '/tmp/localhost_cpu.png', File::WRONLY | File::CREAT || File::TRUNCATE ) { |output|
            output.print( image )
          }

          graph_template = RPerf::GraphTemplate::CPUAverage.new( cpu_average )
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

