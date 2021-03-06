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
      class OutgoingQueries
        include Rocuses::GraphTemplate
        include Rocuses::GraphTemplate::Drawable
        include Rocuses::Utils
        include Rocuses::GraphTemplate::BindStat::BindColors

        GPRINT_FORMAT = '%5.2lf'

        def initialize( bindstat )
          @bindstat = bindstat
        end

        def category
          return "Bind"
        end

        def name
          return 'bind_outgoing_queries' 
        end

        def nodenames
          return [ @bindstat.nodename ]
        end

        def description
          return "Bind Outgoing Queries (RR Type) - #{ @bindstat.nodename }"
        end

        def make_graph()
          title = description()

          graph = RRDTool::Graph.new( :title          => description(),
                                      :lower_limit    => 0,
                                      :vertical_label => 'count/sec',
                                      :rigid          => false )

          @bindstat.outgoing_queries.sort { |a,b|
            line_style_of_rr_type( a[0] )[:priority] <=> line_style_of_rr_type( b[0] )[:priority]
          }.each { |c|
            type  = c[0]
            count = c[1]
            Utils::draw_line( graph,
                              {
                                :label  => sprintf( '%10s', type ),
                                :value  => count,
                                :factor => 1,
                                :width  => 1,
                                :color  => line_style_of_rr_type( type )[:color],
                                :dashes => line_style_of_rr_type( type )[:daches],
                                :format => GPRINT_FORMAT,
                              } )
          }
          return graph
        end
      end
    end
  end
end

