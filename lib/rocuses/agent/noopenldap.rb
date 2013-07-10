# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class NoOpenLDAP
      include Rocuses
      include Log4r

      def initialize( agentconfig )
        @logger = Logger.new( 'rocuses::agent::noopenldap' )
      end

      def name
        return "Rocuses::Agent::NoOpenLDAP"
      end

      def enable_resource?( type )
        return false
      end

      def list_enable_resources()
        return []
      end

      # typeで指定したリソースの統計情報を取得し、resourceにその値を追加する
      # typeで指定したリソースを取得できない場合は、ArgumetErrorをraiseする。
      # type:: リソースのタイプ GET_RESOURCE_METHOD_OFのkeyのいずれか
      # resource:: 取得したリソースの統計情報の保存先
      def get_resource( type, resource )
        return
      end

      # RETURN:: true
      def self.match_environment?( agentconfig )
        return true
      end

      # OpenLDAP Statisticsを取得する
      def get_openldap_statistics( resource )
      end

    end
  end
end

