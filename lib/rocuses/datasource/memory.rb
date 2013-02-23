# -*- coding: utf-8 -*-

module Rocuses
  module DataSource

    class Memory

      # nodename
      attr_reader :nodename

      # Total MemoryのRRDTool::DataSource
      attr_reader :total_memory

      # Used MemoryのRRDTool::DataSource
      attr_reader :used_memory

      # Cache MemoryのRRDTool::DataSource
      attr_reader :cache_memory

      # Buffer MemoryのRRDTool::DataSource
      attr_reader :buffer_memory

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
      end

      def update( config, resource )
        if resource.virtual_memory
          @total_memory  = create_rrd( config, 'total_memory' )
          @used_memory   = create_rrd( config, 'used_memory' )
          @cache_memory  = create_rrd( config, 'cache_memory' )
          @buffer_memory = create_rrd( config, 'buffer_memory' )

          @total_memory.update(  resource.virtual_memory.time, resource.virtual_memory.total_memory )
          @used_memory.update(   resource.virtual_memory.time, resource.virtual_memory.used_memory )
          @cache_memory.update(  resource.virtual_memory.time, resource.virtual_memory.cache_memory )
          @buffer_memory.update( resource.virtual_memory.time, resource.virtual_memory.buffer_memory )
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
