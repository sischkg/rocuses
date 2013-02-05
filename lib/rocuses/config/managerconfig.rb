# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rocuses/config/default'

module Rocuses
  module Config

    # Manager 設定管理
    # リソース取得マネージャの設定を管理する
    #
    #  config = Rocuses::Config::ManagerConfig.new
    #  config.load( File.new( "managerconfig.xml" ) )
    #
    # 設定XMLサンプル
    # <rocuses>
    #   <manager>
    #     <options>
    #       <rrdtool path="/usr/local/bin/rrdtool"/>
    #       <step time="300"/>
    #       <heartbeat step="600"/>
    #       <rra directory="/var/rocuses/rra"/>
    #       <graph directory="/var/rocuses/graph"/>
    #       <image width="500" height="200"/>
    #     </options>
    #   </manager>
    # </rocuses>
    #
    class ManagerConfig

      # rrdtoolコマンドのPATH
      attr_reader :rrdtool_path

      # rrdtoolのrrdファイル作成時のstep
      attr_reader :step

      # rrdtoolのrrdファイル作成時のheartbeat
      attr_reader :heartbeat

      # RRDToolのファイルの保存先ディレクトリ
      attr_reader :rra_directory

      # Grahpの画像ファイルの保存先ディレクトリ
      attr_reader :graph_directory

      # グラフ領域の幅(dots)
      attr_reader :image_width

      # グラフ領域の高さ(dots)
      attr_reader :image_height

      #
      def initialize
        # default values.
        @rrdtool_path    = 'rrdtool'
        @step            = 300
        @heartbeat       = 600
        @rra_directory   = '/var/rocuses/rra' 
        @graph_directory = '/var/rocuses/graph' 
        @image_width     = 500
        @image_height    = 120
      end

      # 設定XMLファイルをロードする
      # input:: 設定XMLファイルのFileオブジェクトなどのIOオブジェクト
      def load( input )
        doc = REXML::Document.new( input )

        @rrdtool_path    = load_option( doc, 'rrdtool',   'path',      @rrdtool_path )
        @step            = load_option( doc, 'step',      'time',      @step ).to_i
        @heartbeat       = load_option( doc, 'heartbeat', 'step',      @heartbeat ).to_i
        @rra_directory   = load_option( doc, 'rra',       'directory', @rra_directory )
        @graph_directory = load_option( doc, 'graph',     'directory', @graph_directory )
        @image_widht     = load_option( doc, 'image',     'width',     @image_width ).to_i
        @image_height    = load_option( doc, 'image',     'height',    @image_height ).to_i
      end

      private

      # <rocuses><manager><options><NAME ATTR="VAR"/></options></manager></rocuses>
      # のVARを取得する。
      # doc:: REXML::Document
      # name:: Elementの名前
      # attr:: 属性の名前
      # default_value:: Elementまたは、attributeが存在しない場合の既定値
      def load_option( doc, name, attr, default_value )
        element = doc.elements["/rocuses/manager/options/#{ name }"]
        if element.nil? || ! element.attributes.key?( attr )
          return default_value
        end
        return element.attributes[attr]
      end

    end
  end
end
