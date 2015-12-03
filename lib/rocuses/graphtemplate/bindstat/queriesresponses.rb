# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    module BindStat
      class QueriesResponses
        include Rocuses::GraphTemplate
        include Rocuses::GraphTemplate::Drawable
        include Rocuses::Utils
        include Rocuses::GraphTemplate::BindStat::BindColors

        GPRINT_FORMAT = '%5.0lf'

        def initialize( bindstat )
          @bindstat = bindstat
        end

        def category
          return "Bind"
        end

        def name
          return 'queries_responses' 
        end

        def nodenames
          return [ @bindstat.nodename ]
        end

        def description
          return "Bind Outgonig Queries/Responses - #{ @bindstat.nodename }"
        end

        def make_graph()
          title = description()

          graph = RRDTool::Graph.new( :title          => description(),
                                      :lower_limit    => 0,
                                      :vertical_label => 'count/sec',
                                      :rigid          => false )
          count_of = {
            'Queries via IPv4'   => @bindstat.resolver_statistics['Queryv4'],
            'Queries via IPv6'   => @bindstat.resolver_statistics['Queryv6'],
            'Responses via IPv4' => @bindstat.resolver_statistics['Responsev4'],
            'Responses via IPv6' => @bindstat.resolver_statistics['Responsev6'],
          }
          count_of.sort { |a,b|
            line_style_of( a[0] )[:priority] <=> line_style_of( b[0] )[:priority]
          }.each { |c|
            type  = c[0]
            count = c[1]
            Utils::draw_line( graph,
                              {
                                :label  => sprintf( '%18s', type ),
                                :value  => count,
                                :factor => 1,
                                :width  => 1,
                                :color  => line_style_of( type )[:color],
                                :dashes => line_style_of( type )[:daches],
                                :format => GPRINT_FORMAT,
                              } )
          }
          return graph
        end
      end
    end
  end
end

