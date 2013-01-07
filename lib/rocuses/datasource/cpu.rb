# -*- coding: utf-8 -*-

require 'pp'
require 'rrdtool/datasource'

module RPerf
  module DataSource

    class CPU

      # nodename
      attr_reader :nodename

      # CPU ID
      attr_reader :name

      # CPU使用率のUSERのRRDTool::DataSource
      attr_reader :user

      # CPU使用率のSYSTEMのRRDTool::DataSource
      attr_reader :system

      # CPU使用率のWAITのRRDTool::DataSource
      attr_reader :wait

      # nodename:: nodename
      # name:: CPU ID
      def initialize( nodename, name ) 
        @nodename = nodename
        @name     = name
      end

      def update( config, resource )
        resource.cpus.each { |cpu|
          if cpu.name == @name
            pp cpu

            @user   = create_rrd( config, 'user' )
            @system = create_rrd( config, 'system' )
            @wait   = create_rrd( config, 'wait' )

            @user.update(   cpu.time, cpu.user )
            @system.update( cpu.time, cpu.system )
            @wait.update(   cpu.time, cpu.wait )
          end
        }
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :COUNTER,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0,
                                      :upper_limit => 200 )
        ds.create
        return ds
      end


      def datasource_name( type )
        return sprintf( '%s_cpu_%s_%s', @nodename, @name, type ) 
      end
    end
  end
end
