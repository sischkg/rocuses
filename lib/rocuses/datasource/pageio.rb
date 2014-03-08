# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class PageIO

      # nodename
      attr_reader :nodename

      # PageInのRRDTool::DataSource
      attr_reader :page_in

      # PageOutのRRDTool::DataSource
      attr_reader :page_out

      # nodename:: nodename
      def initialize( nodename ) 
        @nodename  = nodename
      end

      def update( config, resource )
        @page_in  = create_rrd( config, 'page_in' )
        @page_out = create_rrd( config, 'page_out' )

        @page_in.update(  resource.page_io.time, resource.page_io.page_in )
        @page_out.update( resource.page_io.time, resource.page_io.page_out )
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :DERIVE,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0
                                      )
        ds.create
        return ds
      end


      def datasource_name( type )
        return sprintf( '%s_%s', @nodename, type ) 
      end
    end
  end
end
