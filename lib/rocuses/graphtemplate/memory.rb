# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class Memory
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
        return 'Memory'
      end

      def nodenames
        return [ @vm_datasource.nodename ]
      end

      def description
        return "Memory - #{ @vm_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :rigid          => false,
                                    :vertical_label => "bytes" )

        Utils::draw_area( graph,
                          {
                            :label  => 'total: ',
                            :value  => @vm_datasource.total_memory,
                            :factor => 1,
                            :color  => '#ff9977',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'used:  ',
                            :value  => @vm_datasource.used_memory,
                            :factor => 1,
                            :stack  => false,
                            :color  => '#cc9900',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'buffer:',
                            :value  => @vm_datasource.buffer_memory,
                            :factor => 1,
                            :stack  => true,
                            :color  => '#00ffff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'cache: ',
                            :value  => @vm_datasource.cache_memory,
                            :factor => 1,
                            :stack  => true,
                            :color  => '#ffdd4f',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

