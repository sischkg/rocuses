# -*- coding: utf-8 -*-

require 'pp'
require 'net/http'
require 'log4r'
require 'rexml/document'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class BindStat
      include Rocuses
      include Log4r

      def initialize( agentconfig, bind_info )
        @agentconfig = agentconfig
        @logger      = Logger.new( 'rocuses::agent::bindstat' )
      end

      def name
        return "Rocuses::Agent::BindStat"
      end

      GET_RESOURCE_METHOD_OF = {
        :Bind => :get_bind_statistics,
      }

      def enable_resource?( type )
        return GET_RESOURCE_METHOD_OF.key?( type.to_sym )
      end

      def list_enable_resources()
        return GET_RESOURCE_METHOD_OF.keys
      end

      # typeで指定したリソースの統計情報を取得し、resourceにその値を追加する
      # typeで指定したリソースを取得できない場合は、ArgumetErrorをraiseする。
      # type:: リソースのタイプ GET_RESOURCE_METHOD_OFのkeyのいずれか
      # resource:: 取得したリソースの統計情報の保存先
      def get_resource( type, resource )
        if ! enable_resource?( type )
          raise ArgumentError.new( "not support type #{type}" )
        end
        send( GET_RESOURCE_METHOD_OF[ type.to_sym ], resource )
      end

      # RETURN:: true: connected to statistics channel. 
      def self.match_environment?( agentconfig )
        begin
          body = get_statistics_via_channel( agentconfig )
        rescue => e
          pp e
          return false
        end
        return true
      end


      def get_bind_statistics( resource )
        xml =
          begin
            BindStat.get_statistics_via_channel( @agentconfig )
          rescue => e
            @logger.error( "cannot get bind statistics via channel( #{ e } )" )
          end

        resource.bindstat = parse( xml )
      end

      private

      def self.get_statistics_via_channel( agentconfig )
        begin
          Net::HTTP.start( agentconfig.bind.address, agentconfig.bind.port ) { |http|
            return http.get( '/' ).body
          }
        rescue => e
          pp "cannot get http://#{ agentconfig.bind.address }:#{ agentconfig.bind.port }/ ( #{ e.to_s } )"
          raise e
        end
      end

      KeyOfNsstatName = {
        "Requestv4"    => :request_ipv4,
        "Requestv6"    => :request_ipv6,
        "ReqEdns0"     => :request_edns0,
        "ReqTCP"       => :request_tcp,
        "RecQryRej"    => :rejected_recursiv_request,
        "Response"     => :response,
        "RespEDNS0"    => :response_edns0,
        "QrySuccess"   => :success,
        "QryAuthAns"   => :authorative_answer,
        "QryNoauthAns" => :non_authorative_answer,
        "QryMxrrset"   => :nxrrset,
        "QrySERVFAIL"  => :servfail,
        "QryNXDOMAIN"  => :nxdomain,
        "QryRecursion" => :recursion,
        "QryDuplicate" => :duplicate,
        "QryDropped"   => :dropped,
        "QryFailure"   => :failure,
      }

      KeyOfResstat = {
        "QueryV4"      => :query_ipv4,
        "QueryV6"      => :query_ipv6,
        "ResponseV4"   => :response_ipv4,
        "ResponseV6"   => :response_ipv6,
        "NXDOMAIN"     => :nxdomain,
        "SERVFAIL"     => :servfail,
        "FORMERR"      => :formerr,
        "OtherError"   => :other_error,
        "EDNS0Fail"    => :edns0_fail,
        "Mismatch"     => :mismatch,
        "Truncated"    => :truncated,
        "Lame"         => :lame,
        "Retry"        => :retry,
        "QueryTimeout" => :query_timeout,
      }

      QueryRTT = {
        "QryRTT10"    => :query_rtt_0_10,
        "QryRTT100"   => :query_rtt_10_100,
        "QryRTT500"   => :query_rtt_100_500,
        "QryRTT800"   => :query_rtt_500_800,
        "QryRTT1600"  => :query_rtt_800_1600,
        "QryRTT1600+" => :query_rtt_1600,
      }

      def parse( xml )
        doc = REXML::Document.new( xml )
        return Resource::BindStat.new( :time                       => parse_time( doc ),
                                       :incoming_requests          => parse_incoming_requests( doc ),
                                       :incoming_queries           => parse_incoming_queries( doc ),
                                       :name_server_statistics     => parse_name_server_statistics( doc ),
                                       :zone_mentenance_statistics => parse_zone_mentenance_statistics( doc ),
                                       :socket_io_statistics       => parse_socket_io_statistics( doc ),
                                       :views                      => parse_views( doc ) )
      end

      def parse_time( doc )
        return Time.parse( doc.elements["isc/bind/statistics/server/current-time"].text ) 
      end

      def parse_views( doc )
        views = Array.new
        doc.elements.each( "isc/bind/statistics/views" ) { |view|
          name = view.elements["view/name"].text

          outgoing_queries = Hash.new
          view.elements.each( "view/rdtype" ) { |rdtype|
            outgoing_queries[ rdtype.elements["name"].text ] = rdtype.elements["counter"].text.to_i
          }

          resolver_statistics = Hash.new
          view.elements.each( "view/resstat" ) { |resstat|
            resolver_statistics[ resstat.elements["name"].text ] = resstat.elements["counter"].text.to_i
          }

          cache_db_rrsets = Hash.new
          view.elements.each( "view/cache/rrset" ) { |rrset|
            cache_db_rrsets[ rrset.elements["name"].text ] = rrset.elements["counter"].text.to_i
          }

          view = Resource::BindStat::View.new( :name                => name,
                                               :outgoing_queries    => Resource::BindStat::OutgoingQueries.new( outgoing_queries ),
                                               :resolver_statistics => Resource::BindStat::ResolverStatistics.new( resolver_statistics ),
                                               :cache_db_rrsets     => Resource::BindStat::CacheDBRRSets.new( cache_db_rrsets ) )
          @logger.error( "view #{ view.name }" )
          views.push( view )
        }

        return views
      end

      def parse_counter( doc, path, class_obj )
        counter_of = Hash.new
        doc.elements.each( path ) { |node|
          name    = node.elements["name"].text
          counter = node.elements["counter"].text.to_i
          counter_of[name] = counter
          @logger.error( "#{ path }:#{ name }->#{ counter }" )
        }

        return class_obj.new( counter_of )
      end


      def parse_incoming_requests( doc )
        return parse_counter( doc,
                              "isc/bind/statistics/server/requests/opcode",
                              Resource::BindStat::IncomingRequests )
      end

      def parse_incoming_queries( doc )
        return parse_counter( doc,
                              "isc/bind/statistics/server/queries-in/rdtype",
                              Resource::BindStat::IncomingQueries )
      end

      def parse_name_server_statistics( doc )
        return parse_counter( doc,
                              "isc/bind/statistics/server/nsstat",
                              Resource::BindStat::NameServerStatistics )
      end

      def parse_zone_mentenance_statistics( doc )
        return parse_counter( doc,
                              "isc/bind/statistics/server/zonestat",
                              Resource::BindStat::ZoneMentenanceStatistics )
      end

      def parse_socket_io_statistics( doc )
        return parse_counter( doc,
                              "isc/bind/statistics/server/sockstat",
                              Resource::BindStat::SocketIOStatistics )
      end

    end
  end
end

