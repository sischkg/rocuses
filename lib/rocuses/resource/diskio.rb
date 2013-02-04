# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # DiskIOを保持するクラス
    class DiskIO

      # データ取得時刻(epoch)
      attr_reader :time

      # デバイス名
      attr_reader :name

      # readした回数
      attr_reader :read_count

      # readしたサイズ(byte)
      attr_reader :read_data_size

      # writeした回数
      attr_reader :write_count

      # writeしたサイズ(byte)
      attr_reader :write_data_size

      # Queueが空でない時間(nanosecond)
      attr_reader :wait_time

      # Queue内のIO Requestの数と経過時間の積の和
      attr_reader :queue_length_time

      # time:: データ取得時刻(epoch)
      # name:: デバイス名
      # read_count:: readした回数
      # read_data_size:: readしたサイズ(byte)
      # write_count:: writeした回数
      # write_data_size:: writeしたサイズ(byte)
      # wait_time:: Queueが空でない時間(nanosecond)
      # queue_length_time:: Queue内のIO Requestの数と経過時間(nanoseocnd)の積の和
      def initialize( args )
        Rocuses::Utils::check_args( args,
                                    {
                                      :time              => :req,
                                      :name              => :req,
                                      :read_count        => :req,
                                      :read_data_size    => :req,
                                      :write_count       => :req,
                                      :write_data_size   => :req,
                                      :wait_time         => :req,
                                      :queue_length_time => :req,
                                    } )
        
        
        @time              = args[:time]
        @name              = args[:name]
        @read_count        = args[:read_count]
        @read_data_size    = args[:read_data_size]
        @write_count       = args[:write_count]
        @write_data_size   = args[:write_data_size]
        @wait_time         = args[:wait_time]
        @queue_length_time = args[:queue_length_time]
      end
    end
  end
end