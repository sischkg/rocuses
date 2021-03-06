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
          symbols = [
                     'Queryv4',
                     'Queryv6',
                     'Responsev4',
                     'Responsev6',
                    ]
          symbols.sort { |a,b|
            line_style_of_query_response_by_resolver( a )[:priority] <=> line_style_of_query_response_by_resolver( b )[:priority]
          }.each { |symbol|
            Utils::draw_line( graph,
                              {
                                :label  => sprintf( '%18s', description_of_query_response_by_resolver( symbol ) ),
                                :value  => @bindstat.resolver_statistics[symbol],
                                :factor => 1,
                                :width  => 1,
                                :color  => line_style_of_query_response_by_resolver( symbol )[:color],
                                :dashes => line_style_of_query_response_by_resolver( symbol )[:daches],
                                :format => GPRINT_FORMAT,
                              } )
          }
          return graph
        end
      end
    end
  end
end

