# -*- coding: utf-8 -*-

require 'rperf/utils'

module RPerf
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

      # read/wait待ち状態の数
      attr_reader :wait_count

      # read/wait状態の数
      attr_reader :run_count

      # soft error count
      attr_reader :soft_error_count

      # hard error count
      attr_reader :hard_error_count

      # transport error count
      attr_reader :transport_error_count

      # time:: データ取得時刻(epoch)
      # name:: デバイス名
      # read_count:: readした回数
      # read_data_size:: readしたサイズ(byte)
      # write_count:: writeした回数
      # write_data_size:: writeしたサイズ(byte)
      # wait_count:: read/wait待ち状態の数
      # run_count:: read/wait状態の数
      # soft_error_count:: soft error count
      # hard_error_count:: hard error count
      # transport_error_count:: transport error count
      def initialize( args )
        RPerf::Utils::check_args( args,
                                  {
                                    :time             => :req,
                                    :name             => :req,
                                    :read_count       => :req,
                                    :read_data_size   => :req,
                                    :write_count      => :req,
                                    :write_data_size  => :req,
                                    :wait_count       => :req,
                                    :run_count        => :req,
                                    :soft_error_count => :req,
                                    :hard_error_count => :req,
                                    :transport_error_count => :req,
                                  } )
        
        
        @time            = args[:time]
        @name            = args[:name]
        @read_count      = args[:read_count]
        @read_data_size  = args[:read_data_size]
        @write_count     = args[:write_count]
        @write_data_size = args[:write_data_size]
        @wait_count      = args[:wait_count]
        @run_count       = args[:run_count]
        @soft_error_count      = args[:soft_error_count]
        @hard_error_count      = args[:hard_error_count]
        @transport_error_count = args[:transport_error_count]
      end
    end
  end
end
