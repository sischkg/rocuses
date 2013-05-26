# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LoadAverage
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.2lf'

      def initialize( load_average_datasource )
        @load_average_datasource = load_average_datasource
      end

      def name
        return 'LoadAverage'
      end

      def filename
        return 'LoadAverage'
      end

      def nodenames
        return [ @load_average_datasource.nodename ]
      end

      def description
        return "Load Average - #{ @load_average_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title       => description(),
                                    :lower_limit => 0,
                                    :rigid       => false )

        Utils::draw_line( graph,
                          {
                            :label  => '1 minute:  ',
                            :value  => @load_average_datasource.la1,
                            :factor => 1,
                            :width  => 1,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => '5 minutes: ',
                            :value  => @load_average_datasource.la5,
                            :factor => 1,
                            :width  => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => '15 minutes:',
                            :value  => @load_average_datasource.la15,
                            :factor => 1,
                            :width  => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

