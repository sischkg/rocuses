# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource
    # メモリ・スワップの利用状況
    class VirtualMemory

      # データ取得時刻(epoch time);
      attr_reader :time

      # メモリ使用量(byte)
      attr_reader :used_memory

      # 全メモリ(byte)
      attr_reader :total_memory

      # キャッシュメモリ(byte)
      attr_reader :cache_memory

      # バッファメモリ(byte)
      attr_reader :buffer_memory

      # スワップ使用量(byte)
      attr_reader :used_swap

      # 全スワップ(byte)
      attr_reader :total_swap

      # データ取得時刻(epoch time);
      # used_memory:: メモリ使用量(byte)
      # total_memory:: 全メモリ(byte)
      # cache_memory:: キャッシュメモリ(byte)
      # buffer_memory:: バッファメモリ(byte)
      # used_swap:: スワップ使用量(byte)
      # total_swap:: 全スワップ(byte)
      def initialize( args )
        Utils::check_args( args, 
                           {
                             :time          => :req,
                             :used_memory   => :req,
                             :total_memory  => :req,
                             :cache_memory  => :op,
                             :buffer_memory => :op,
                             :used_swap     => :req,
                             :total_swap    => :req,
                           } )
        @time          = args[:time]
        @used_memory   = args[:used_memory]
        @total_memory  = args[:total_memory]
        @cache_memory  = args.key?( :cache_memory ) ? args[:cache_memory] : 0
        @buffer_memory = args.key?( :buffer_memory ) ? args[:buffer_memory] : 0
        @used_swap     = args[:used_swap]
        @total_swap    = args[:total_swap]
      end
    end
  end

  # ページイン・ページアウトしたページ数
  class PageIO

    # データ取得時刻(epoch time);
    attr_reader :time

    # ページインしたページ数
    attr_reader :page_in

    # ページアウトしたページ数
    attr_reader :page_out

    # データ取得時刻(epoch time);
    # page_in:: ページインしたページ数
    # page_out::　ページアウトしたページ数
    def initialize( time, page_in, page_out )
      @time     = time
      @page_in  = page_in
      @page_out = page_out
    end
  end
end

