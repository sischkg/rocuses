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
      class ResolverErrors
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
          return 'resolver_errors' 
        end

        def nodenames
          return [ @bindstat.nodename ]
        end

        def description
          return "Bind Resolver Error responses - #{ @bindstat.nodename }"
        end

        def make_graph()
          title = description()

          graph = RRDTool::Graph.new( :title          => description(),
                                      :lower_limit    => 0,
                                      :vertical_label => 'count/sec',
                                      :rigid          => false )

          count_of = {
            'Lame'          => @bindstat.resolver_statistics['Lame'],
            'Retry'         => @bindstat.resolver_statistics['Retry'],
            'QueryAbort'    => @bindstat.resolver_statistics['QueryAbort'],
            'QuerySockFail' => @bindstat.resolver_statistics['QuerySockFail'],
            'QueryTimeout'  => @bindstat.resolver_statistics['QueryTimeout'],
          }
          count_of.sort { |a,b|
            line_style_of_resolver_error_by_resolver( a[0] )[:priority] <=> line_style_of_resolver_error_by_resolver( b[0] )[:priority]
          }.each { |c|
            type  = c[0]
            count = c[1]
            Utils::draw_line( graph,
                              {
                                :label  => sprintf( '%14s', description_of_resolver_error_by_resolver( type ) ),
                                :value  => count,
                                :factor => 1,
                                :width  => 1,
                                :color  => line_style_of_resolver_error_by_resolver( type )[:color],
                                :dashes => line_style_of_resolver_error_by_resolver( type )[:daches],
                                :format => GPRINT_FORMAT,
                              } )
          }
          return graph
        end
      end
    end
  end
end

