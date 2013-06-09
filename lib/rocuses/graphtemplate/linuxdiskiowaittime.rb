# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class LinuxDiskIOWaitTime
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
        return sprintf( 'linux_disk_io_wait_time_%s', @disk_io_datasource.name )
      end

      def nodenames
        return [ @disk_io_datasource.nodename ]
      end

      def description
        return "Disk IO Wait Time - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :upper_limit    => 1,
                                    :rigid          => true,
                                    :vertical_label => 'Wait Time' )

        Utils::draw_line( graph,
                          {
                            :label  => 'wait:',                            
                            :value  => @disk_io_datasource.wait_time,
                            :factor => 1.0 / ( 1000 * 1000 * 1000 ),
                            :width  => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

