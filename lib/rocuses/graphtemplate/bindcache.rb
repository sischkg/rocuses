# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class BindCache
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%7.0lf'

      LINE_STYLE_OF = {
        'A'        => { :color => '#ff0000', :daches => false, :priority => 100, },
        '!A'       => { :color => '#ff0000', :daches => true,  :priority => 101, },
        'PTR'      => { :color => '#00ff00', :daches => false, :priority => 110, },
        '!PTR'     => { :color => '#00ff00', :daches => true,  :priority => 111, },
        'MX'       => { :color => '#0000ff', :daches => false, :priority => 120, },
        '!MX'      => { :color => '#0000ff', :daches => true,  :priority => 121, },
        'NS'       => { :color => '#ff00ff', :daches => false, :priority => 130, },
        '!NS'      => { :color => '#ff00ff', :daches => true,  :priority => 131, },
        'AAAA'     => { :color => '#990000', :daches => false, :priority => 140, },
        '!AAAA'    => { :color => '#990000', :daches => true,  :priority => 141, },
        'CNAME'    => { :color => '#000000', :daches => false, :priority => 200, },
        'NXDOMAIN' => { :color => '#000000', :daches => true,  :priority => 211, },
        'DS'       => { :color => '#000099', :daches => false, :priority => 300, },
        '!DS'      => { :color => '#000099', :daches => true,  :priority => 301, },
        'NSEC'     => { :color => '#009900', :daches => false, :priority => 310, },
        '!NSEC'    => { :color => '#009900', :daches => true,  :priority => 311, },
        'DNSKEY'   => { :color => '#009999', :daches => false, :priority => 320, },
        '!DNSKEY'  => { :color => '#999900', :daches => true,  :priority => 321, },
        'RRSIG'    => { :color => '#990099', :daches => false, :priority => 330, },
        '!RRSIG'   => { :color => '#990099', :daches => true,  :priority => 331, },
        'DLV'      => { :color => '#999999', :daches => false, :priority => 340, },
        '!DLV'     => { :color => '#999999', :daches => true,  :priority => 341, },
      }

      DEFAULT_LINE_STYLE = {
        :color => '#cccccc', :daches => false, :priority => 999999,
      }

      LINE_STYLE_OF.default = DEFAULT_LINE_STYLE

      def initialize( bindcache_datasource )
        @bindcache_datasource = bindcache_datasource
      end

      def name
        return sprintf( 'bindcache_%s', @bindcache_datasource.view )
      end

      def category
        return "Bind"
      end

      def nodenames
        return [ @bindcache_datasource.nodename ]
      end

      def description
        return "Bind Cache  - #{ @bindcache_datasource.view } of #{ @bindcache_datasource.nodename }"
      end

      def make_graph()
        title = description()

        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :upper_limit    => 10 * 1000 * 1000 * 1000,
                                    :vertical_label => 'count',
                                    :rigid          => false )

        @bindcache_datasource.cache.sort { |a,b|
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

