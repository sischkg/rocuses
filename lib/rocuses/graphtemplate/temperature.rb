# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class Temperature
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%4.1lf'

      def initialize( temperature_datasource )
        @temperature_datasource = temperature_datasource
      end

      def category
        return "Temperature"
      end

      def name
        return 'Temperature'
      end

      def nodenames
        return [ @temperature_datasource.nodename ]
      end

      def description
        return "Temperature - #{ @tempurature_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title       => description(),
                                    :lower_limit => -273,
                                    :upper_limit => 200,
                                    :rigid       => false )

        Utils::draw_line( graph,
                          {
                            :label  => 'temperature: ',
                            :value  => @temperature_datasource.temperature,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

