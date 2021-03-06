# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # サーバ上の個々のファイルシステムの情報を保持するクラス
    class Filesystem

      # データ取得時刻
      attr_reader :time

      # mount point
      attr_reader :mount_point

      # 容量(bytes)
      attr_reader :total_size

      # 使用量(bytes)
      attr_reader :used_size
      
      # 空き容量(byte)
      attr_reader :free_size

      # 全inode
      attr_reader :total_files

      # 使用inode
      attr_reader :used_files

      # time:: データ取得時刻
      # mount_point:: mount point
      # total_size:: 容量(bytes)
      # used_size:: 使用量(bytes)
      # free_size:: 空き容量(byte)
      # total_files:: 全inode
      # used_files:: 使用inode
      def initialize( args )
        Utils::check_args( args,
                           {
                             :time        => :req,
                             :mount_point => :req,
                             :total_size  => :req,
                             :used_size   => :req,
                             :free_size   => :req,
                             :total_files => :req,
                             :used_files  => :req,
                           } )
        @time        = args[:time]
        @mount_point = args[:mount_point]
        @total_size  = args[:total_size]
        @used_size   = args[:used_size]
        @free_size   = args[:free_size]
        @total_files = args[:total_files]
        @used_files  = args[:used_files]
      end

      # 空きinode数
      def free_files()
        return @total_files - @used_files
      end

    end
  end
end
