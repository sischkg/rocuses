# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class CPUAverage

      # nodename
      attr_reader :nodename

      # CPU使用率のUSERのRRDTool::DataSource
      attr_reader :user

      # CPU使用率のSYSTEMのRRDTool::DataSource
      attr_reader :system

      # CPU使用率のWAITのRRDTool::DataSource
      attr_reader :wait

      # CPU数
      attr_reader :cpu_count

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
        @cpu_count = 1
      end

      def update( config, resource )
        if resource.cpu_average
          @user   = create_rrd( config, 'user' )
          @system = create_rrd( config, 'system' )
          @wait   = create_rrd( config, 'wait' )

          @user.update(   resource.cpu_average.time, resource.cpu_average.user )
          @system.update( resource.cpu_average.time, resource.cpu_average.system )
          @wait.update(   resource.cpu_average.time, resource.cpu_average.wait )
        end

        if resource.cpus
          @cpu_count = resource.cpus.size
        end
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
        return sprintf( '%s_cpu_average_%s', @nodename, type ) 
      end
    end
  end
end
