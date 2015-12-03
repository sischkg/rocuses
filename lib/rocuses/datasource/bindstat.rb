# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class BindStat

      # nodename
      attr_reader :nodename

      attr_reader :incoming_requests

      attr_reader :incoming_queries

      attr_reader :name_server_statistics

      attr_reader :zone_mentenance_statistics

      attr_reader :socket_io_statistics

      attr_reader :outgoing_queries

      attr_reader :resolver_statistics

      attr_reader :cache_db_rrsets

      def initialize( nodename )
        @nodename = nodename
      end

      def update( config, resource )
        if resource.bindstat
          @incoming_requests = update_counter( :time     => resource.bindstat.time,
                                               :config   => config,
                                               :resource => resource.bindstat.incoming_requests,
                                               :prefix   => "incoming_requests",
                                               :dst      => :DERIVE )
          @incoming_queries = update_counter( :time     => resource.bindstat.time,
                                              :config   => config,
                                              :resource => resource.bindstat.incoming_queries,
                                              :prefix   => "incoming_queries",
                                              :dst      => :DERIVE )
          @zone_mentenance_statistics = update_counter( :time     => resource.bindstat.time,
                                                        :config   => config,
                                                        :resource => resource.bindstat.zone_mentenance_statistics,
                                                        :prefix   => "zone_mentenance_statistics",
                                                        :dst      => :DERIVE )
          @socket_io_statistics = update_counter( :time     => resource.bindstat.time,
                                                  :config   => config,
                                                  :resource => resource.bindstat.socket_io_statistics,
                                                  :prefix   => "socket_io_statistics",
                                                  :dst      => :DERIVE )
          @outgoing_queries = update_counter( :time     => resource.bindstat.time,
                                              :config   => config,
                                              :resource => resource.bindstat.outgoing_queries,
                                              :prefix   => "outgoing_queries",
                                              :dst      => :DERIVE )
          @resolver_statistics = update_counter( :time     => resource.bindstat.time,
                                                 :config   => config,
                                                 :resource => resource.bindstat.resolver_statistics,
                                                 :prefix   => "resolver_statistics",
                                                 :dst      => :DERIVE )
          @cache_db_rrsets = update_counter( :time     => resource.bindstat.time,
                                             :config   => config,
                                             :resource => resource.bindstat.cache_db_rrsets,
                                             :prefix   => "cache_db_rrsets",
                                             :dst      => :GAUGE )
        end
      end

      private

      def create_rrd( config, prefix, name, dst  )
        ds = RRDTool::DataSource.new( :name        => datasource_name( prefix, name ),
                                      :type        => dst,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def update_counter( args )
        args = Utils::check_args( args,
                                  {
                                    :config   => :req,
                                    :time     => :req,
                                    :resource => :req,
                                    :prefix   => :req,
                                    :dst      => :op,
                                  },
                                  {
                                    :dst => :DERIVE,
                                  } )
        param = Hash.new
        args[:resource].each { |k,v|
          param[k] = create_rrd( args[:config], args[:prefix], k, args[:dst] )
          param[k].update( args[:time], v )
        }
        return param
      end

      def datasource_name( prefix, name )
        return sprintf( '%s_bindstat_%s_%s', @nodename, prefix, name )
      end
    end
  end
end
