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

        @filesystems = Array.new
        resource.filesystems.each { |filesystem|
          if check_filesystem?( filesystem.mount_point )
            filesystem_ds = DataSource::Filesystem.new( @target.name, filesystem.mount_point )
            filesystem_ds.update( manager_config, resource )
            @filesystems << filesystem_ds
          end
        }
      end

      def make_graph_templates
        graph_templates = Array.new

        graph_templates << GraphTemplate::CPU.new( @cpu_usages )
        graph_templates << GraphTemplate::CPUAverage.new( @cpu_average_usage )
        graph_templates << GraphTemplate::Memory.new( @memory )

        @filesystems.each { |filesystem|
          graph_templates << GraphTemplate::FilesystemSize.new( filesystem )
        }

        return graph_templates
      end

      def make_graph_template( type )

      end

      private
      
      # ファイルシステムの使用量取得対象あるかを判定する
      # mount_point:: ファイルシステムのmount_point
      # RETURN:: true: mount_pointは使用量取得対象である / false: mountは使用量取得対象ではない
      def check_filesystem?( mount_point )
        ManagerParameters::SKIP_FILESYSTEMS.each { |pattern|
          if mount_point =~ pattern
            return false
          end
        }
        return true
      end
    end
  end
end
