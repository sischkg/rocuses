# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/utils'

module Rocuses
  class Graph
    include Rocuses

    # 画像データ
    attr_reader :image

    # グラフ名
    attr_reader :name

    # 画像ファイル名
    attr_reader :filename

    # グラフの期間の開始時刻のTimeオブジェクト
    attr_reader :begin_time

    # グラフの期間の終了時刻のTimeオブジェクト
    attr_reader :end_time

    # :image:: 画像データ
    # :name:: グラフ名
    # :filename:: 画像ファイル名
    # :begin_time:: グラフの期間の開始時刻のTimeオブジェクト
    # :end_time:: グラフの期間の終了時刻のTimeオブジェクト
    def initialize( args )
      Utils::check_args( args, {
                           :image      => :req,
                           :name       => :req,
                           :filename   => :req,
                           :begin_time => :req,
                           :end_time   => :req,
                         } )

      @image      = args[:image]
      @name       = args[:name]
      @filename   = args[:filename]
      @begin_time = args[:begin_time]
      @end_time   = args[:end_time]

    end

  end
end


