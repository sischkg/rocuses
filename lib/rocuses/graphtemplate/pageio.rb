# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class PageIO
      include Rocuses
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.0lf %%'

      def initialize( page_io_datasource )
        @page_io_datasource = page_io_datasource
      end

      def template_name()
        return 'Page_IO'
      end

      def id()
        return template_name
      end

      def filename()
        return template_name
      end

      def nodenames
        return [ @page_io_datasource.nodename ]
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

