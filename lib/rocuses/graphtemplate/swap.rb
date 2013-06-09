# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class Swap
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.2lf %SB'

      def initialize( vm_datasource )
        @vm_datasource = vm_datasource
      end

      def category
        return "Virtual Memory"
      end

      def name
        return 'Swap'
      end

      def nodenames
        return [ @vm_datasource.nodename ]
      end

      def description
        return "Swap - #{ @vm_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'bytes',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'total: ',
                            :value  => @vm_datasource.total_swap,
                            :factor => 1,
                            :color  => '#ff9977',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'used:  ',
                            :value  => @vm_datasource.used_swap,
                            :factor => 1,
                            :stack  => false,
                            :color  => '#cc9900',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

