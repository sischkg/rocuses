# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # Load Averageを保持するクラス
    class LoadAverage

      # データ取得時刻(epoch)
      attr_reader :time

      # 1 minute load average
      attr_reader :la1

      # 5 minutes load average
      attr_reader :la5

      # 15 minutes load avarage
      attr_reader :la15

      # time:: データ取得時刻(epoch)
      # la1:: 1 minute load average
      # la5:: 5 minutes load average
      # la15:: 15 minutes load avarage
      def initialize( args )
        Rocuses::Utils::check_args( args,
                                    {
                                      :time => :req,
                                      :la1 =>  :req,
                                      :la5  => :req,
                                      :la15 => :req,
                                    } )
        @time = args[:time]
        @la1  = args[:la1]
        @la5  = args[:la5]
        @la15 = args[:la15]
      end
    end
  end
end
