# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class NoBind
      include Rocuses
      include Log4r

      def initialize( bind_info )
        @logger = Logger.new( 'rocuses::agent::nobind' )
      end

      def name
        return "Rocuses::Agent::NoBind"
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

      # RETURN:: true: Bind 9.8, 9.7, 9.6 
      def self.match_environment?
        return true
      end

      # Name Server Statisticsを取得する
      def get_bind_statistics( resource )
      end

    end
  end
end

