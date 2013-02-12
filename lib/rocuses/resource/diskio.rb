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

      # time:: データ取得時刻(epoch)
      # name:: デバイス名
      # read_count:: readした回数
      # read_data_size:: readしたサイズ(byte)
      # write_count:: writeした回数
      # write_data_size:: writeしたサイズ(byte)
      def initialize( args )
        Utils::check_args( args,
                           {
                             :time              => :req,
                             :name              => :req,
                             :read_count        => :req,
                             :read_data_size    => :req,
                             :write_count       => :req,
                             :write_data_size   => :req,
                           } )
        
        
        @time              = args[:time]
        @name              = args[:name]
        @read_count        = args[:read_count]
        @read_data_size    = args[:read_data_size]
        @write_count       = args[:write_count]
        @write_data_size   = args[:write_data_size]
      end
    end
  end
end
