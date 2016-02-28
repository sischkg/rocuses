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
      class ReceivedErrors
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
          return 'received_errors' 
        end

        def nodenames
          return [ @bindstat.nodename ]
        end

        def description
          return "Bind Received Error responses - #{ @bindstat.nodename }"
        end

        def make_graph()
          title = description()

          graph = RRDTool::Graph.new( :title          => description(),
                                      :lower_limit    => 0,
                                      :vertical_label => 'count/sec',
                                      :rigid          => false )

          count_of = {
            'NXDOMAIN'   => @bindstat.resolver_statistics['NXDOMAIN'],
            'SERVFAIL'   => @bindstat.resolver_statistics['SERVFAIL'],
            'FORMERR'    => @bindstat.resolver_statistics['FORMERR'],
            'OtherError' => @bindstat.resolver_statistics['OtherError'],
            'EDNS0Fail'  => @bindstat.resolver_statistics['EDNS0Fail'],
            'Mismatch'   => @bindstat.resolver_statistics['Mismatch'],
            'Truncated'  => @bindstat.resolver_statistics['Truncated'],
          }
          count_of.sort { |a,b|
            line_style_of_received_error_by_resolver( a[0] )[:priority] <=> line_style_of_received_error_by_resolver( b[0] )[:priority]
          }.each { |c|
            type  = c[0]
            count = c[1]
            Utils::draw_line( graph,
                              {
                                :label  => sprintf( '%10s', description_of_received_error_by_resolver( type ) ),
                                :value  => count,
                                :factor => 1,
                                :width  => 1,
                                :color  => line_style_of_received_error_by_resolver( type )[:color],
                                :dashes => line_style_of_received_error_by_resolver( type )[:daches],
                                :format => GPRINT_FORMAT,
                              } )
          }
          return graph
        end
      end
    end
  end
end

