# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class BindQuery
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%7.0lf'

      LINE_STYLE_OF = {
        'A'        => { :color => '#ff0000', :daches => false, :priority => 100, },
        'PTR'      => { :color => '#00ff00', :daches => false, :priority => 110, },
        'MX'       => { :color => '#0000ff', :daches => false, :priority => 120, },
        'NS'       => { :color => '#ff00ff', :daches => false, :priority => 130, },
        'AAAA'     => { :color => '#990000', :daches => false, :priority => 140, },
        'CNAME'    => { :color => '#000000', :daches => false, :priority => 200, },
        'NXDOMAIN' => { :color => '#000000', :daches => true,  :priority => 211, },
        'DS'       => { :color => '#000099', :daches => false, :priority => 300, },
        'NSEC'     => { :color => '#009900', :daches => false, :priority => 310, },
        'DNSKEY'   => { :color => '#009999', :daches => false, :priority => 320, },
        'RRSIG'    => { :color => '#990099', :daches => false, :priority => 330, },
        'DLV'      => { :color => '#999999', :daches => false, :priority => 340, },
      }

      DEFAULT_LINE_STYLE = {
        :color => '#cccccc', :daches => false, :priority => 999999,
      }

      LINE_STYLE_OF.default = DEFAULT_LINE_STYLE

      def initialize( bindquery_datasource, direction )
        @bindquery_datasource = bindquery_datasource
        @direction = direction
      end

      def name
        return sprintf( 'bindquery_%s', @direction )
      end

      def category
        return "Bind"
      end

      def nodenames
        return [ @bindquery_datasource.nodename ]
      end

      def description
        return "Bind #{ @direction == :in ? "Incoming" : "Outgoing" } Query - # of #{ @bindquery_datasource.nodename }"
      end

      def make_graph()
        title = description()

        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :upper_limit    => 10 * 000 * 000 * 000,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        @bindquery_datasource.queries_of.sort { |a,b|
          LINE_STYLE_OF[a[0]][:priority] <=> LINE_STYLE_OF[b[0]][:priority]
        }.each { |record|
          type       = record[0]
          count      = record[1]
          line_style = LINE_STYLE_OF[type]

          Utils::draw_line( graph,
                            {
                              :label  => sprintf( '%10s', type ),
                              :value  => count,
                              :factor => 1,
                              :width  => 1,
                              :color  => line_style[:color],
                              :dashes => line_style[:dashes],
                              :format => GPRINT_FORMAT,
                            } )
        }
        return graph
      end
    end
  end
end

