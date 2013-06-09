# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'net/ldap'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class OpenLDAP
      include Rocuses
      include Log4r

      def initialize( agentconfig )
        @agentconfig = agentconfig
        @bind_info   = bind_info
        @logger      = Logger.new( 'rocuses::agent::openldap' )
      end

      def name
        return "Rocuses::Agent::OpenLDAP"
      end

      GET_RESOURCE_METHOD_OF = {
        :Bind      => :get_openldap_statistics,
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

      # RETURN:: net/ldapをロード可能である: true
      def self.match_environment?( agentconfig )
        begin 
          require 'net/ldap'
          return true
        rescue LoadError => e
          return false
        end
      end


      def get_openldap_statistics( resource )
      end

      private

    end
  end
end

