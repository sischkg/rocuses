# -*- coding: utf-8 -*-

require 'rperf/utils'

module RPerf
  class Resource

    # ネットワークインターフェース情報を保持するクラス
    class NetworkInterface

      # データ取得時刻(epoch)
      attr_reader :time

      # ネットワークインターフェース名
      attr_reader :name

      # 受信したパケット数
      attr_reader :inbound_packet_count

      # 受信したデータサイズ(byte)
      attr_reader :inbound_data_size

      # 受信時のエラー数
      attr_reader :inbound_error_count
      
      # 送信したパケット数
      attr_reader :outbound_packet_count

      # 送信したデータサイズ(byte)
      attr_reader :outbound_data_size

      # 送信時のエラー数
      attr_reader :outbound_error_count

      # status
      attr_reader :link_status

      # time::                 データ取得時刻(epoch)
      # name::                 ネットワークインターフェース名
      # inbound_packet_count:: 受信したパケット数
      # inbound_data_size::    受信したデータサイズ(byte)
      # inbound_error_count::  受信時のエラー数
      # outbound_packet_cunt:: 送信したパケット数
      # outbound_data_size::   送信したデータサイズ(byte)
      # outbound_error_count:: 送信時のエラー数
      def initialize( args )
        RPerf::Utils::check_args( args,
                                  {
                                    :time                  => :req,
                                    :name                  => :req,
                                    :inbound_packet_count  => :req,
                                    :inbound_data_size     => :req,
                                    :inbound_error_count   => :req,
                                    :outbound_packet_count => :req,
                                    :outbound_data_size    => :req,
                                    :outbound_error_count  => :req,
                                    :link_status           => :req,
                                  } )
        
        
        @time                  = args[:time]
        @name                  = args[:name]
        @inbound_packet_count  = args[:inbound_packet_count]
        @inbound_data_size     = args[:inbound_data_size]
        @inbound_error_count   = args[:inbound_error_count]
        @outbound_packet_count = args[:outbound_packet_count]
        @outbound_data_size    = args[:outbound_data_size]
        @outbound_error_count  = args[:outbound_error_count]
        @link_status           = args[:link_status]
      end
    end
  end
end
