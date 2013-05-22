# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # BINDキャッシュ情報を保持するクラス
    class BindCache 
      include Rocuses
      include Comparable

      # データ取得時刻
      attr_reader :time

      attr_reader :view

      attr_reader :cache

      # ::time データ取得時刻
      # ::cache
      # ::view
      def initialize( args )
        Utils::check_args( args, 
                           {
                             :time     => :req,
                             :view     => :req,
                             :cache    => :req,
                           } )
        @time  = args[:time]
        @view  = args[:view]
        @cache = args[:cache]
      end

      def set_chache( type, count )
        @cache[type] = count
      end

      def get_cache( type )
        if @cache.key?( type )
          return @cache[type]
        end
        return 0
      end

      def <=>( other )
        view_diff = ( @view <=> other.view )
        if view_diff
          return view_diff
        end
        return @cache <=> other.cache
      end

    end
  end
end
