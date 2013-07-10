# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class Bind
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.0lf'

      def initialize( bind_datasource )
        @bind_datasource = bind_datasource
      end

      def category
        return "Bind"
      end

      def name
        return 'bind' 
      end

      def nodenames
        return [ @bind_datasource.nodename ]
      end

      def description
        return "Bind Name Server Statistics - #{ @bind_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        Utils::draw_line( graph,
                          {
                            :label  => 'success:     ',
                            :value  => @bind_datasource.success,
                            :factor => 1,
                            :color  => '#000000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'nxrrset:     ',
                            :value  => @bind_datasource.nxrrset,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'nxdomain:    ',
                            :value  => @bind_datasource.nxdomain,
                            :factor => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'servfail:    ',
                            :value  => @bind_datasource.servfail,
                            :factor => 1,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'recursion:   ',
                            :value  => @bind_datasource.recursion,
                            :factor => 1,
                            :color  => '#ff00ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'request ipv4:',
                            :value  => @bind_datasource.request_ipv4,
                            :factor => 1,
                            :color  => '#ffff00',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

