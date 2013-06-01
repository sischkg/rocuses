# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class BindQuery
      include Rocuses

      # nodename
      attr_reader :nodename

      # direction
      attr_reader :direction

      attr_reader :queries_of

      # nodename:: nodename
      # direction:: :in or :out
      def initialize( nodename, direction )
        @nodename  = nodename
        @direction = direction
      end

      def update( config, resource )
        @queries_of = Hash.new
        if resource.bind
          queries_of = resource.bind.outgoing_queries_of
          if @direction == :in
            queries_of = resource.bind.incoming_queries_of
          end

          queries_of.each { |type,count|
            @queries_of[type] = create_rrd( config, type )
            @queries_of[type].update( resource.bind.time, count )
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
        return sprintf( '%s_bindquery_%s_%s',
                        @nodename,
                        @direction,
                        Utils::escape_name( type ) )
      end
    end
  end
end
