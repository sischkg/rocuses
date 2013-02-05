# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # サーバ上の個々のプロセスの情報を保持するクラス
    class Process

      # プロセスのコマンドとその引数
      attr_reader :argument

      # プロセスの起動時刻(second)
      attr_reader :start_time

      # メモリサイズ(byte)
      attr_reader :size

      # PID
      attr_reader :pid

      # 親PID
      attr_reader :parent_pid

      # UID
      attr_reader :uid

      # GID
      attr_reader :gid

      # 監視時刻
      attr_reader :time
      
      # argument:: プロセスのコマンドとその引数
      # start_time:: プロセスの起動時刻(second)
      # size:: メモリサイズ(byte)
      # pid:: PID
      # parent_pid:: 親PID
      # uid:: UID
      # gid:: GID
      # time:: 監視時刻
      def initialize( args )
        Utils::check_args( args,
                           {
                             :time       => :req,
                             :argument   => :req,
                             :start_time => :req,
                             :size       => :op,
                             :pid        => :req,
                             :parent_pid => :req,
                             :uid        => :req,
                             :gid        => :req,
                           } )
        @time       = args[:time]
        @argument   = args[:argument]
        @start_time = args[:start_time]
        @size       = args[:size]
        @pid        = args[:pid]
        @parent_pid = args[:parent_pid]
        @uid        = args[:uid]
        @gid        = args[:gid]
      end
    end

  end
end
