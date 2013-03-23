# -*- coding: utf-8 -*-

require 'rocuses/utils'
require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'

module Rocuses
  module GraphTemplate
    module Utils

      module_function

      # graph:: Rocuses::RRDTool::Graph
      # args::
      # :label:: 系列名
      # :value:: グラフデータのRocuses::RRDTool::DataSource
      # :color:: line color
      # :gprint:: true: グラフの下部に、Current/Average/Maximumを表示する / false: 表示しない
      # :format:: gprint:がtrueの場合の、Current/Average/Maximusの値のフォーマット 
      # :width:: line width( default: 1 )
      # :stack:: true: グラフの線を重ねる
      # :factor:: valueに掛ける係数( default: 1 )
      # :daches:: true: 破線 / false: 実線(default: false)
      def draw_line( graph, args )
        args = Rocuses::Utils::check_args( args,
                                           {
                                             :label  => :req,
                                             :value  => :req,
                                             :color  => :req,
                                             :format => :op,
                                             :width  => :op,
                                             :stack  => :op,
                                             :factor => :op,
                                             :dashes => :op,
                                             :gprint => :op,
                                           },
                                           {
                                             :format => '%5lf',
                                             :width  => 1,
                                             :stack  => false,
                                             :factor => 1.0,
                                             :dashes => false,
                                             :gprint => true,
                                           } )

        draw_item( graph, :line, args )

        return graph
      end

      # graph:: Rocuses::RRDTool::Graph
      # args::
      # :label:: 系列名
      # :value:: グラフデータのRocuses::RRDTool::DataSource
      # :color:: line color
      # :gprint:: true: グラフの下部に、Current/Average/Maximumを表示する / false: 表示しない
      # :format:: gprint:がtrueの場合の、Current/Average/Maximusの値のフォーマット 
      # :stack:: true: グラフの線を重ねる
      # :factor:: valueに掛ける係数( default: 1 )
      def draw_area( graph, args )
        args = Rocuses::Utils::check_args( args,
                                           {
                                             :label  => :req,
                                             :value  => :req,
                                             :color  => :req,
                                             :format => :req,
                                             :stack  => :op,
                                             :factor => :op,
                                             :gprint => :op,
                                           },
                                           {
                                             :stack  => false,
                                             :factor => 1.0,
                                             :gprint => true,
                                           } )

        draw_item( graph, :area, args )

        return graph
      end

      def draw_item( graph, type, args )
        args = Rocuses::Utils::check_args( args,
                                           {
                                             :label  => :req,
                                             :value  => :req,
                                             :color  => :req,
                                             :format => :req,
                                             :width  => :op,
                                             :stack  => :op,
                                             :factor => :op,
                                             :dashes => :op,
                                             :gprint => :op,
                                           } )

        item = RRDTool::RPN_DataSource.new( args[:value], :AVERAGE ) * args[:factor]
        if args[:gprint]
          average = RRDTool::RPN_DataSource.new( args[:value], :AVERAGE ) * args[:factor]
          maximum = RRDTool::RPN_DataSource.new( args[:value], :MAX     ) * args[:factor] 
          last    = RRDTool::RPN_DataSource.new( args[:value], :LAST )    * args[:factor]
        end

        if type == :line
          graph.add_item( RRDTool::Line.new(
                                            :value  => item,
                                            :width  => args[:width],
                                            :stack  => args[:stack],
                                            :color  => args[:color],
                                            :label  => args[:label],
                                            :dashes => args[:dashes]
                                            ) )
        else
          graph.add_item( RRDTool::Area.new( 
                                            :value  => item,
                                            :stack  => args[:stack],
                                            :color  => args[:color],
                                            :label  => args[:label]
                                            ) )
        end

        if args[:gprint]
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Last.new( last ),
                                               :format => "Current: #{ args[:format] }" ) )
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Average.new( average ),
                                               :format => "Average: #{ args[:format] }" ) )
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Maximum.new( maximum ),
                                               :format => "Maximum: #{ args[:format] }" ) )
        end
        graph.add_item( RRDTool::LineFeed.new( :left ) )

        return graph
      end
    end
  end
end

