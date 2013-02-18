# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class LoadAverage

      # nodename
      attr_reader :nodename

      # 1分間LoadAverageのRRDTool::DataSource
      attr_reader :la1

      # 5分間LoadAverageのRRDTool::DataSource
      attr_reader :la5

      # 15分間LoadAverageのRRDTool::DataSource
      attr_reader :la15

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
      end

      def update( config, resource )
        @la1  = create_rrd( config, 'la1' )
        @la5  = create_rrd( config, 'la5' )
        @la15 = create_rrd( config, 'la15' )

        @la1.update(  resource.load_average.time, resource.load_average.la1 )
        @la5.update(  resource.load_average.time, resource.load_average.la5 )
        @la15.update( resource.load_average.time, resource.load_average.la15 )
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
        return sprintf( '%s_load_average_%s', @nodename, type ) 
      end
    end
  end
end
