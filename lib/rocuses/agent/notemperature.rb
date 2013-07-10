# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class NoTemperature
      include Rocuses
      include Log4r

      def initialize( agentconfig, path )
        @logger = Logger.new( 'rocuses::agent::notemperature' )
      end

      def name
        return "Rocuses::Agent::NoTemperature"
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

      def get_temperature( resource )
      end
      
      # RETURN:: true
      def self.match_environment?( agentconfig )
        return true
      end

    end
  end
end

