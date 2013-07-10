# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class Temperature

      # nodename
      attr_reader :nodename

      # 温度（摂氏）
      attr_reader :temperature

      # 湿度(%)
      attr_reader :humidity

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
      end

      def update( config, resource )
        @temperature = create_rrd( config, 'temperature' )
        @humidity    = create_rrd( config, 'humidity' )

        @temperature.update(  resource.temperature.time, resource.temperature.temperature )
        @humidity.  .update(  resource.temperature.time, resource.temperature.humidity )
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :GAUGE,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end


      def datasource_name( type )
        return sprintf( '%s_temperature_%s', @nodename, type ) 
      end
    end
  end
end
