# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class BindCache
      include Rocuses::GraphTemplate
      include Rocuses::Utils

      GPRINT_FORMAT = '%7lf'

      def initialize( bindcache_datasource )
        @bindcache_datasource = bindcache_datasource
      end

      def name
        return sprintf( 'bindcache_%s', escape_name( @bindcache.view ) )
      end

      def filename
        return sprintf( 'bindcache_%s', escape_name( @bindcache.view ) )
      end

      def nodenames
        return [ @bindcache_datasource.nodename ]
      end

      def make_graph()
        title = "Bind Cache  - #{ @bindcache_datasource.view } of #{ @bindcache_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
                                    :lower_limit    => 0,
                                    :upper_limit    => 10 * 000 * 000 * 000,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        @bindcache.cache.each { |type,count|
          Utils::draw_line( graph,
                            {
                              :label  => 'type:',
                              :value  => count,
                              :factor => 1,
                              :width  => 1,
                              :color  => '#0000ff',
                              :format => GPRINT_FORMAT,
                            } )
        }
        return graph
      end
    end
  end
end

