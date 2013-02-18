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

        if resource.load_average
          @load_average = DataSource::LoadAverage.new( @target.name )
          @load_average.update( manager_config, resource )
        end

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

        @disk_ios = Array.new
        resource.disk_ios.each { |disk_io|
          disk_io_ds = DataSource::DiskIO.new( @target.name, disk_io.name )
          disk_io_ds.update( manager_config, resource )
          @disk_ios << disk_io_ds
        }

        @linux_disk_ios = Array.new
        resource.linux_disk_ios.each { |disk_io|
          disk_io_ds = DataSource::LinuxDiskIO.new( @target.name, disk_io.name )
          disk_io_ds.update( manager_config, resource )
          @linux_disk_ios << disk_io_ds
        }

        @network_interfaces = Array.new
        resource.network_interfaces.each { |nic|
          nic_ds = DataSource::NetworkInterface.new( @target.name, nic.name )
          nic_ds.update( manager_config, resource )
          @network_interfaces << nic_ds
        }
      end

      def make_graph_templates
        graph_templates = Array.new

        graph_templates << GraphTemplate::CPU.new( @cpu_usages )
        graph_templates << GraphTemplate::CPUAverage.new( @cpu_average_usage )

        if @load_average
          graph_templates << GraphTemplate::LoadAverage.new( @load_average )
          graph_templates << GraphTemplate::LoadAverageMax.new( @load_average )
        end

        graph_templates << GraphTemplate::Memory.new( @memory )
        graph_templates << GraphTemplate::Swap.new( @swap )
        if @page_io
          graph_templates << GraphTemplate::PageIO.new( @page_io )
        end

        @filesystems.each { |filesystem|
          graph_templates << GraphTemplate::FilesystemSize.new( filesystem )
          graph_templates << GraphTemplate::FilesystemFiles.new( filesystem )
        }

        @disk_ios.each { |disk_io|
          graph_templates << GraphTemplate::DiskIOSize.new( disk_io )
          graph_templates << GraphTemplate::DiskIOCount.new( disk_io )
        }

        @linux_disk_ios.each { |disk_io|
          graph_templates << GraphTemplate::LinuxDiskIOWaitTime.new( disk_io )
          graph_templates << GraphTemplate::LinuxDiskIOQueueLength.new( disk_io )
        }

        @network_interfaces.each { |nic|
          graph_templates << GraphTemplate::Traffic.new( :network_interface_datasources => [ nic ] )
          graph_templates << GraphTemplate::NICError.new( nic )
        }

        return graph_templates
      end

      def make_graph_template( type )

      end

    end
  end
end
