# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # BIND統計情報を保持するクラス
    class BindStat
      include Rocuses
      include Comparable

      class CounterDB
        def initialize( counter_of )
          @counter_of = counter_of
        end

        def []( attr )
          attr = attr.to_s
          @counter_of[attr] ? @counter_of[attr] : 0
        end

        def each( &block )
          @counter_of.each { |key,value|
            block.call( key,value )
          }
        end
      end

      class IncomingRequests < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class IncomingQueries < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class NameServerStatistics < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class ZoneMentenanceStatistics < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class SocketIOStatistics < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class OutgoingQueries < CounterDB
       def initialize( args )
          super( args )
        end
      end

      class ResolverStatistics < CounterDB
        def initialize( args )
          super( args )
        end
      end

      class CacheDBRRSets < CounterDB

        def initialize( args )
          super( args )
        end

        def cache( rr )
          return count_cache( /\A[^\!\#]/ )
        end

        def negative_cache
          return count_cache( /\A\!/ )
        end

        def gabage_collect
          return count_cache( /\A\#/ )
        end

        private

        def count_cache( pattern )
          count_of = Hash.new
          each { |k,v|
            if k =~ pattern
              count_of[k] += v
            end
          }
          return count_of
        end
      end

      class View
        attr_reader :name
        attr_reader :outgoing_queries
        attr_reader :resolver_statistics
        attr_reader :cache_db_rrsets

        def initialize( args )
          Utils::check_args( args,
                             {
                               :name                => :req,
                               :outgoing_queries    => :req,
                               :resolver_statistics => :req,
                               :cache_db_rrsets     => :req,
                             } )

          @name                = args[:name]
          @outgoing_queries    = args[:outgoing_queries]
          @resolver_statistics = args[:resolver_statistics]
          @cache_db_rrsets     = args[:cache_db_rrsets]
        end
      end

      attr_reader :time

      attr_reader :incoming_requests

      attr_reader :incoming_queries

      attr_reader :name_server_statistics

      attr_reader :zone_mentenance_statistics

      attr_reader :socket_io_statistics

      attr_reader :views

      def initialize( args )
        Utils::check_args( args,
                           {
                             :time                       => :req,
                             :incoming_requests          => :req,
                             :incoming_queries           => :req,
                             :name_server_statistics     => :req,
                             :zone_mentenance_statistics => :req,
                             :socket_io_statistics       => :req,
                             :views                      => :req,
                           } )

        @time                       = args[:time]
        @incoming_requests          = args[:incoming_requests]
        @incoming_queries           = args[:incoming_queries]
        @name_server_statistics     = args[:name_server_statistics]
        @zone_mentenance_statistics = args[:zone_mentenance_statistics]
        @socket_io_statistics       = args[:socket_io_statistics]
        @views                      = args[:views]
      end

      def outgoing_queries
        return count_over_views( OutgoingQueries, :outgoing_queries )
      end

      def resolver_statistics
        return count_over_views( ResolverStatistics, :resolver_statistics )
      end

      def cache_db_rrsets
        return count_over_views( CacheDBRRSets, :cache_db_rrsets )
      end

      private

      def count_over_views( db_class, method_name )
        count_of = Hash.new { |hash, key|
          hash[key] = 0
        }

        @views.each { |view|
          view.send( method_name ).each { |k,v|
            count_of[k] += v
          }
        }
        return db_class.new( count_of )
      end

    end
  end
end

