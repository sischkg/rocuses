# -*- coding: utf-8 -*-

require 'rocuses/device/unixserver'
require 'rocuses/managerparameters'

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

        @memory = DataSource::Memory.new( @target.name )
        @memory.update( manager_config, resource )
        @swap = DataSource::Swap.new( @target.name )
        @swap.update( manager_config, resource )

        if resource.page_io
          @page_io = DataSource::PageIO.new( @target.name )
          @page_io.update( manager_config, resource )
        end

        @filesystems = Array.new
        resource.filesystems.each { |filesystem|
          filesystem_ds = DataSource::Filesystem.new( @target.name, filesystem.mount_point )
          filesystem_ds.update( manager_config, resource )
          @filesystems << filesystem_ds
        }
      end

      def make_graph_templates
        graph_templates = Array.new

        graph_templates << GraphTemplate::CPU.new( @cpu_usages )
        graph_templates << GraphTemplate::CPUAverage.new( @cpu_average_usage )
        graph_templates << GraphTemplate::Memory.new( @memory )
        graph_templates << GraphTemplate::Swap.new( @swap )
        if @page_io
          graph_templates << GraphTemplate::PageIO.new( @page_io )
        end

        @filesystems.each { |filesystem|
          graph_templates << GraphTemplate::FilesystemSize.new( filesystem )
          graph_templates << GraphTemplate::FilesystemFiles.new( filesystem )
        }

        return graph_templates
      end

      def make_graph_template( type )

      end

    end
  end
end
