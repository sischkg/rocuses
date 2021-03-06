# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class NICError
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.0lf'

      def initialize( network_interface_datasource )
        @network_interface_datasource = network_interface_datasource
      end

      def category
        return "Network Interface"
      end

      def name
        return sprintf( 'nic_error_%s', @network_interface_datasource.name )
      end

      def nodenames
        return [ @network_interface_datasource.nodename ]
      end

      def description
        return "NetworkInterface Error - #{ @network_interface_datasource.name } of #{ @network_interface_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'inbound: ',
                            :value  => @network_interface_datasource.inbound_error_count,
                            :factor => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'outbound:',
                            :value  => @network_interface_datasource.outbound_error_count,
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

