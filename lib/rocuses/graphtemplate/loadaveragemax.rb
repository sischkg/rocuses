# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LoadAverageMax
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.2lf'

      def initialize( load_average_datasource )
        @load_average_datasource = load_average_datasource
      end

      def name
        return 'LoadAverageMax'
      end

      def filename
        return 'LoadAverageMax'
      end

      def make_graph()
        title = "Load Average(Max) - #{ @load_average_datasource.nodename }"

        graph = RRDTool::Graph.new( :title       => title,
                                    :lower_limit => 0,
                                    :rigid       => false )

        Utils::draw_area( graph,
                          {
                            :label  => '1 minute(average):  ',
                            :value  => @load_average_datasource.la1,
                            :factor => 1,
                            :color  => '#eacc00',
                            :format => GPRINT_FORMAT,
                          } )

        graph.add_item( RRDTool::Line.new( :label  => '5 minutes: ',
                                           :value  => RRDTool::RPN_DataSource.new( @load_average_datasource.la1, :MAX ),
                                           :width  => 1,
                                           :color  => '#ea8f00' ) )
        graph.add_item( RRDTool::LineFeed.new( :left ) )
        return graph
      end
    end
  end
end
