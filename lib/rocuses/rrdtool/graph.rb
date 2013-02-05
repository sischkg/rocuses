# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  module RRDTool
    # グラフへLineを表示する
    class Line
      include Rocuses

      AVAILABLE_LINE_WIDTH = [ 1, 2, 3 ]

      attr_reader :value, :color, :width, :label, :stack, :dashes

      # value:: RPN
      # color:: 色( #rrggbb 形式の文字列)
      # label:: 
      # stack:: true:stackあり/false:stackなし(default)
      # dashes:: 点線( see rrdgraph )
      def initialize( args )
        args = Utils::check_args( args,
                                  {
                                    :value  => :req,
                                    :width  => :op,
                                    :color  => :op,
                                    :label  => :req,
                                    :stack  => :op,
                                    :dashes => :op
                                  },
                                  {
                                    :width  => 1,
                                    :color  => '#000000',
                                    :stack  => false,
                                    :dashed => false,
                                  } )
        @value  = args[:value]
        @width  = args[:width]
        @color  = args[:color]
        @label  = args[:label]
        @stack  = args[:stack]
        @dashes = args[:dashes]

        if ! AVAILABLE_LINE_WIDTH.include?( @width )
          raise %Q[ invalid line width "#{ @width }", must be 1 or 2, 3]
        end
        if @value.is_vdef
          raise %Q[ RPM "#{ @value }" must be CDEF( do not contain DEF ).]
        end
        
      end

      def depend_on
        return @value.depend_on()
      end

      def definitions()
        return %q{}
      end

      def rpn_expression()
        e = sprintf( %q{LINE%d:%s%s:"%s"},
                     @width,
                     @value.name,
                     @color,
                     @label )
        if @stack
          e += ":STACK"
        end
        if @dashes
          e += ":dashes"
        end
        return e
      end
    end


    # グラフへAreaを表示する
    class Area
      include Rocuses

      attr_reader :value, :color, :label, :stack

      # value:: RPN
      # color:: 色( #rrggbb 形式の文字列)
      # label:: 
      # stack:: true:stackあり/false:stackなし(default)
      def initialize( args )
        args = Utils::check_args( args,
                                  {
                                    :value  => :req,
                                    :color  => :op,
                                    :label  => :req,
                                    :stack  => :op,
                                  },
                                  {
                                    :color  => '#000000',
                                    :stack  => false,
                                  } )
        @value  = args[:value]
        @color  = args[:color]
        @label  = args[:label]
        @stack  = args[:stack]
        
        if @value.is_vdef
          raise %Q[ RPM "#{ @value }" must be CDEF( do not contain DEF ).]
        end
      end

      def depend_on
        return @value.depend_on()
      end

      def definition()
        return %q{}
      end

      def rpn_expression()
        e = sprintf( %q{AREA:%s%s:"%s"},
                     @value.name,
                     @color,
                     @label )
        if @stack
          e += ":STACK"
        end
        return e
      end
    end


    # グラフ内へDS(データソース)の値を追加する
    class GPrint
      include Rocuses

      attr_reader :value, :format

      # value:: RPN
      # format:表示フォーマット 
      def initialize( args )
        Utils::check_args( args,
                           {
                             :value  => :req,
                             :format => :req
                           } )

        @value  = args[:value]
        @format = args[:format]

        if ! @value.is_vdef
          raise %Q[GPrint use only VDEF value but "#{ @value.name }" is not VDEF.]
        end
      end

      def depend_on
        return @value.depend_on()
      end

      def definition()
        return %q{}
      end

      def rpn_expression()
        return sprintf( %q{GPRINT:%s:"%s"},
                        @value.name,
                        @format.gsub( ':', "" ) )
      end
    end

    # グラフ内のコメント
    class Comment
      include Rocuses

      attr_reader :comment

      # ::comment コメントの文字列
      def initialize( args )
        Utils::check_args( args,
                           {
                             :comment => :req,
                           } )
        @comment = args[:commet]
      end

      def depend_on
        return []
      end

      def definition
        return %q{}
      end

      def rpm_expression()
        return sprintf( %q{COMMENT:"%s"}, @comment )
      end
    end


    # グラフ内の改行
    class LineFeed
      include Rocuses

      def initialize( align = nil )
        if align == :center
          @align = "\\c"
        elsif align == :right
          @align = "\\r"
        elsif align == :left
          @align = "\\l"
        else
          @align = "\\n"
        end
      end

      def depend_on
        return []
      end

      def definition
        return %q{}
      end

      def rpn_expression()
        return %Q["COMMENT:#{@align}"]
      end

    end


    #
    # RRDToolのグラフを作成するクラス
    class Graph
      include Rocuses

      # title:: グラフのタイトル
      # vertical_label:: グラフの縦軸のラベル
      # begin_time::グラフの開始時刻
      # end_time:: グラフの終了時刻
      # lower_limit:: グラフの下限値
      # upper_limit:: グラフの上限値
      # width:: グラフの幅
      # height:: グラフの高さ
      # rigid:: true:autoscaleなし / false:autoscaleあり(default)
      def initialize( args )
        args = Utils::check_args( args,
                                  {
                                    :title          => :op,
                                    :vertical_label => :op,
                                    :begin_time     => :op,
                                    :end_time       => :op,
                                    :upper_limit    => :op,
                                    :lower_limit    => :op,
                                    :width          => :op,
                                    :height         => :op,
                                    :rigid          => :op,
                                  },
                                  {
                                    :title          => nil,
                                    :vertical_label => nil,
                                    :width          => 500,
                                    :height         => 200,
                                    :rigid          => false,
                                  } )
        if args[:end_time]
          @end_time = args[:end_time]
        else
          @end_time = Time.now
        end
        if args[:begin_time]
          @begin_time = @end_time - 60 * 60 * 24
        end

        @title          = args[:title]
        @vertical_label = args[:vertical_label]
        @lower_limit    = args[:lower_limit]
        @upper_limit    = args[:upper_limit]
        @width          = args[:width]
        @height         = args[:height]
        @rigid          = args[:rigid]

        @items = Array.new
      end

      # グラフへGraphItemを追加する
      # item:: GraphItem
      def add_item( item )
        @items.push( item )
        return self
      end

      # グラフ画像を作成する
      # title:: グラフのタイトル
      # begin_time:: グラフの開始時刻のTimeオブジェクト
      # end_time:: グラフの終了時刻のTimeオブジェクト
      # lower_limit:: グラフの最小値
      # upper_limit:: グラフの最大値
      # vertical_label:: Y軸のラベル
      # rigid:: autoscale
      # RETURN:: グラフ画像（png)
      def make_image( args )
        args = Utils::check_args( args,
                                  {
                                    :title          => :op,
                                    :begin_time     => :op,
                                    :end_time       => :op,
                                    :lower_limit    => :op,
                                    :upper_limit    => :op,
                                    :width          => :op,
                                    :height         => :op,
                                    :vertical_label => :op,
                                    :rigid          => :op,
                                  },
                                  {
                                    :title          => @title,
                                    :vertical_label => @vertical_label,
                                    :begin_time     => @begin_time,
                                    :end_time       => @end_time,
                                    :lower_limit    => @lower_limit,
                                    :upper_limit    => @upper_limit,
                                    :width          => @width,
                                    :height         => @height,
                                    :rigit          => @rigid,
                                  } )

        title          = args[:title]
        begin_time     = args[:begin_time]
        end_time       = args[:end_time]
        lower_limit    = args[:lower_limit]
        upper_limit    = args[:upper_limit]
        width          = args[:width]
        height         = args[:height]
        vertical_label = args[:vertical_label]
        rigid          = args[:rigid]

        cmd =
          %Q[ --slope-mode ] +
          %Q[ --start #{ begin_time.to_i } --end #{ end_time.to_i } ] +
          %Q[ --width #{ width } --height #{ height } ]

        if ! title.nil?
          cmd += %Q[ --title "#{ title }" ]
        end

        if ! vertical_label.nil?
          cmd += %Q[ --vertical-label '#{ vertical_label } ' ]
        end

        if ! lower_limit.nil?
          cmd += " --lower-limit #{ lower_limit } "
        end
        if ! upper_limit.nil?
          cmd += " --upper-limit #{ upper_limit } "
        end
        if rigid 
          cmd += " --rigid "
        end

        cmd += sprintf( %q[ COMMENT:"from %s to %s\\c" ],
                        begin_time.strftime( "%Y/%m/%d %H\\:%M" ),
                        end_time.strftime( "%Y/%m/%d %H\\:%M" ) )
        cmd += %q[ COMMENT:"\\n" ]

        depend_values = Array.new
        @items.each { |item|
          depend_values += item.depend_on()
        }

        depend_values.uniq.each { |value|
          cmd += sprintf( " %s ", value.definition() )
        }

        @items.each { |item|
          cmd += sprintf( " %s ", item.rpn_expression )
        }

        return RRDTool.make_image( cmd )
      end
    end
  end
end
