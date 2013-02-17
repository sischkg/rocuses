# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LinuxDiskIOWaitTime
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def name
        return 'linux_disk_io_wait_time'
      end

      def filename
        return sprintf( 'linux_disk_io_wait_time_%s', @disk_io_datasource.name.gsub( %r{[/ ]}, %q{_} ) )
      end

      def make_graph()
        title = "Disk IO Wait Time - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
                                    :lower_limit    => 0,
                                    :upper_limit    => 1,
                                    :rigid          => true,
                                    :vertical_label => 'Wait Time' )

        Utils::draw_area( graph,
                          {
                            :label  => 'wait:',
                            :value  => @disk_io_datasource.wait_time,
                            :factor => 1000 * 1000 * 1000,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

