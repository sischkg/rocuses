# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class BindCache
      include Rocuses

      # nodename
      attr_reader :nodename

      # view
      attr_reader :view

      attr_reader :cache

      # nodename:: nodename
      def initialize( nodename, view )
        @nodename = nodename
        @view     = view
      end

      def update( config, resource )
        if resource.bindcaches
          resource.bindcaches.each { |cache|
            if cache.view == @view
              @cache = Hash.new
              cache.cache.each { |type, count|
                @cache[type] = create_rrd( config, type )
                @cache[type].update( cache.time, count )
              }
            end
          }
        end
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :COUNTER,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_bindcache_%s_%s',
                        @nodename,
                        @view,
                        Utils::escape_name( type ) )
      end
    end
  end
end
