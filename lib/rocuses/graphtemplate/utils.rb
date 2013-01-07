# -*- coding: utf-8 -*-

require 'rrdtool/rpn'
require 'rrdtool/graph'

module Rocuses
  module GraphTemplate
    module Utils

      module_function

      def draw_line( graph, args )
        args = Args::check_args( args,
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
                                 },
                                 {
                                   :width  => 1,
                                   :stack  => false,
                                   :factor => 1.0,
                                   :dash   => false,
                                   :gprint => true,
                                 } )


        line    = RRDTool::RPN_DataSource.new( args[:value], :AVERAGE ) * args[:factor]
        if args[:gprint]
          average = RRDTool::RPN_DataSource.new( args[:value], :AVERAGE ) * args[:factor]
          maximum = RRDTool::RPN_DataSource.new( args[:value], :MAX     ) * args[:factor] 
          last    = RRDTool::RPN_DataSource.new( args[:value], :LAST )    * args[:factor]
        end
        graph.add_item( RRDTool::Line.new( :value  => line,
                                           :width  => args[:width],
                                           :stack  => args[:stack],
                                           :color  => args[:color],
                                           :label  => args[:label],
                                           :dashes => args[:dashes] ) )

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

