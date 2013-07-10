# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource
    # 温度・湿度
    class Temperature

      # データ取得時刻
      attr_reader :time

      # 温度(摂氏)
      attr_reader :temperature

      # 湿度(%)
      attr_reader :humidity

      # :time データ取得時刻
      # :temperature:: 温度(摂氏)
      # :humidity:: 湿度(%)
      def initialize( args )
        Utils::check_args( args, 
                           {
                             :time        => :req,
                             :temperature => :req,
                             :humidity    => :req,
                           } )
        @time        = args[:time]
        @temperature = args[:temperature]
        @humidity    = args[:humidity]
      end
    end
  end
end
