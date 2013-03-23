# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class Swap

      # nodename
      attr_reader :nodename

      # Total SwapのRRDTool::DataSource
      attr_reader :total_swap

      # Used SwapのRRDTool::DataSource
      attr_reader :used_swap

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
      end

      def update( config, resource )
        if resource.virtual_memory
          @total_swap  = create_rrd( config, 'total_swap' )
          @used_swap   = create_rrd( config, 'used_swap' )

          @total_swap.update( resource.virtual_memory.time, resource.virtual_memory.total_swap )
          @used_swap.update(  resource.virtual_memory.time, resource.virtual_memory.used_swap )
        end
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
        return sprintf( '%s_%s', @nodename, type ) 
      end
    end
  end
end
