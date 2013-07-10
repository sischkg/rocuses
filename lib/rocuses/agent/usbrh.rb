# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class Usbrh
      include Rocuses
      include Log4r

      COMMAND_PATHS = [ '/usr/sbin/usbrh', '/usr/local/sbin/usbrh' ]

      def initialize( agentconfig, usbrh_path )
        @usbrh_path = usbrh_path
        @logger = Logger.new( 'rocuses::agent::usbrh' )
      end

      def name
        return "Rocuses::Agent:Usbrh"
      end

      def enable_resource?( type )
        if type.to_sym == :Temperature
          return true
        else
          return false
        end
      end

      def list_enable_resources()
        return [ :Temperature ]
      end

      # typeで指定したリソースの統計情報を取得し、resourceにその値を追加する
      # typeで指定したリソースを取得できない場合は、ArgumetErrorをraiseする。
      # type:: リソースのタイプ GET_RESOURCE_METHOD_OFのkeyのいずれか
      # resource:: 取得したリソースの統計情報の保存先
      def get_resource( type, resource )
        if ! enable_resource?( type )
          return
        end

        get_temperature( resource )
      end

      def get_temperature( resource )
        IO.popen( @usbrh_path ) { |input|
          line = input.gets
          if line =~ /\A([\d\.]+)\s+([\d\.]+)\s*/
            resource.temperature = Resource::Temperature.new( :time        => Time.now,
                                                              :temperature => $1.to_f,
                                                              :humidity    => $2.to_f )
          end
        }
      end

      # RETURN:: true
      def self.match_environment?( agentconfig )
        COMMAND_PATHS.each { |path|
          if File.executable?( path )
            return path
          end
        }
        return nil
      end

    end
  end
end

