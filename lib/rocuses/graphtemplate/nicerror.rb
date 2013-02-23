# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class NICError
      include Rocuses
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.0lf'

      def initialize( network_interface_datasource )
        @network_interface_datasource = network_interface_datasource
      end

      def template_name()
        return 'NICError'
      end

      def id()
        return sprintf( '%s_%s', template_name, @network_interface_datasource.name )
      end

      def filename()
        return sprintf( '%s_%s',
                        template_name,
                        Rocuses::Utils::escape_for_filename( @network_interface_datasource.name ) )
      end

      def make_graph()
        title = "NetworkInterface Error - #{ @network_interface_datasource.name } of #{ @network_interface_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
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

