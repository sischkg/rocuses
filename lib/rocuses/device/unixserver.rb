# -*- coding: utf-8 -*-

require 'rocuses/device/unixserver'

module Rocuses
  module Device
    class UnixServer
      include Rocuses

      def initialize( target )
        @target = target
      end

      def name
        @target.name
      end

      def update( manager_config, resource )
        @cpu_usages = Array.new
        resource.cpus.each { |cpu|
          cpu_usage = DataSource::CPU.new( @target.name, cpu.name )
          cpu_usage.update( manager_config, resource )
          @cpu_usages << cpu_usage
        }

        @cpu_average_usage = DataSource::CPUAverage.new( @target.name )
        @cpu_average_usage.update( manager_config, resource )          
      end

      def make_graph_templates
        graph_templates = Array.new

        graph_templates << GraphTemplate::CPU.new( @cpu_usages )
        graph_templates << GraphTemplate::CPUAverage.new( @cpu_average_usage )
        
        return graph_templates
      end

      def make_graph_template( type )

      end

    end
  end
end
