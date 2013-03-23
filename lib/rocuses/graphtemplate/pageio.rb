# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class PageIO
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.0lf %%'

      def initialize( page_io_datasource )
        @page_io_datasource = page_io_datasource
      end

      def name
        return 'Page_IO'
      end

      def filename
        return 'Page_IO'
      end

      def make_graph()
        title = "Page IO - #{ @page_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
                                    :lower_limit    => 0,
                                    :vertical_label => 'pages per second',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'page in: ',
                            :value  => @page_io_datasource.page_in,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'page out:',
                            :value  => @page_io_datasource.page_out,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

