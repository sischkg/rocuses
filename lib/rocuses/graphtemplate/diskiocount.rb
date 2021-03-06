# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class DiskIOCount
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def category
        return "Disk I/O"
      end

      def name
        return sprintf( 'disk_io_count_%s', @disk_io_datasource.name )
      end

      def nodenames
        return [ @disk_io_datasource.nodename ]
      end

      def description
        return "Disk IO Count - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :upper_limit    => 10 * 000 * 000 * 000,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'read: ',
                            :value  => @disk_io_datasource.read_count,
                            :factor => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'write:',
                            :value  => @disk_io_datasource.write_count,
                            :factor => 1,
                            :width  => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

