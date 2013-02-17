# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # Linux独自のDiskIOを保持するクラス
    class LinuxDiskIO

      # データ取得時刻(epoch)
      attr_reader :time

      # デバイス名
      attr_reader :name

      # Queueが空でない時間(nanosecond)
      attr_reader :wait_time

      # Queue内のIO Requestの数と経過時間の積の和(n * nanosecond)
      attr_reader :queue_length_time

      # time:: データ取得時刻(epoch)
      # name:: デバイス名
      # wait_time:: Queueが空でない時間(nanosecond)
      # queue_length_time:: Queue内のIO Requestの数と経過時間(nanoseocnd)の積の和
      def initialize( args )
        Utils::check_args( args,
                           {
                             :time              => :req,
                             :name              => :req,
                             :wait_time         => :req,
                             :queue_length_time => :req,
                           } )
                
        @time              = args[:time]
        @name              = args[:name]
        @wait_time         = args[:wait_time]
        @queue_length_time = args[:queue_length_time]
      end
    end
  end
end
