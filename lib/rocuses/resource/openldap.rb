# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # OpenLDAP統計情報(monitor)を保持するクラス
    class OpenLDAP
      include Rocuses

      # データ取得時刻
      attr_reader :time

      # 起動してからの接続数
      attr_reader :total_connection

      # 同時接続数
      attr_reader :concurrent_connection

      # MAX File Descriptor
      attr_reader :max_file_descriptor

      # bind operation
      attr_reader :bind_operation

      # unbind operation
      attr_reader :unbind_operation

      # search operation
      attr_reader :search_operation

      # comapre operation
      attr_reader :compare_operation

      # modify operation
      attr_reader :modify_operation

      # modrdn operation
      attr_reader :modrdn_operation

      # add operation
      attr_reader :add_operation

      # delete operation
      attr_reader :delete_operation

      # abandon operation
      attr_reader :abandon_operation

      # extended operation
      attr_reader :extended_operation

      # :time:: データ取得時刻
      # :total_connection:: 起動してからの接続数
      # :concurrent_connection:: 同時接続数
      # :max_file_descriptor:: MAX File Descriptor
      # :bind_operation:: bind operation count
      # :unbind_operation:: unbind operation count
      # :search_operation:: search operation count
      # :compare_operation:: comapre operation count
      # :modify_operation:: modify operation count
      # :modrdn_operation:: modrdn operation count
      # :add_operation:: add operation count
      # :delete_operation:: delete operation count
      # :abandon_operation:: abandon operation count
      # :extended_operation:: extended operation count
      attr_reader :extended_operation
      def initialize( args )
        args = Utils::check_args( args,
                                  {
                                    :time                  => :req,
                                    :total_connection      => :req,
                                    :concurrent_connection => :req,
                                    :max_file_descriptor   => :req,
                                    :bind_operation        => :req,
                                    :unbind_operation      => :req,
                                    :search_operation      => :req,
                                    :compare_operation     => :req,
                                    :modify_operation      => :req,
                                    :modrdn_operation      => :req,
                                    :add_operation         => :req,
                                    :delete_operation      => :req,
                                    :abandon_operation     => :req,
                                    :extended_operation    => :req,
                                  } )

        @time                  = args[:time]
        @total_connection      = args[:total_connection]
        @concurrent_connection = args[:concurrent_connection]
        @max_file_descriptor   = args[:max_file_descriptor]
        @bind_operation        = args[:bind_operation]
        @unbind_operation      = args[:unbind_operation]
        @search_operation      = args[:search_operation]
        @compare_operation     = args[:compare_operation]
        @modify_operation      = args[:modify_operation]
        @modrdn_operation      = args[:modrdn_operation]
        @add_operation         = args[:add_operation]
        @delete_operation      = args[:delete_operation]
        @abandon_operation     = args[:abandon_operation]
        @extended_operation    = args[:extended_operation]
      end
    end

    class OpenLDAPCache

      # データ取得時刻
      attr_reader :time

      # IDL Cache
      attr_reader :idl_cache

      # Entry Cache
      attr_reader :entry_cache

      # DN Cache :dn_cache
      attr_reader :dn_cache

      # Database Directory
      attr_reader :directory

      # :time:: データ取得時刻
      # :idl_cache:: IDL Cache
      # :entry_cache:: Entry Cache
      # :dn_cache:: DN Cache
      # :diretory:: Database Directory
      #
      def initialize( args )
        Utils::check_args( args,
                           {
                             :time        => :req,
                             :idl_cache   => :req,
                             :entry_cache => :req,
                             :dn_cache    => :req,
                             :directory   => :req,
                           } )
        @time        = args[:time]
        @idl_cache   = args[:idl_cache]
        @entry_cache = args[:entry_cache]
        @dn_cache    = args[:dn_cache]
        @directory   = args[:directory]
      end
    end

  end
end

