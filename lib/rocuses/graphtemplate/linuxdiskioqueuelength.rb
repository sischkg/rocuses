# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LinuxDiskIOQueueLength
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def name
        return 'linux_disk_io_queue_length'
      end

      def filename
        return sprintf( 'linux_disk_io_queue_length_%s', @disk_io_datasource.name.gsub( %r{[/ ]}, %q{_} ) )
      end

      def make_graph()
        title = "Disk IO Queue Length - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
                                    :lower_limit    => 0,
                                    :rigid          => false,
                                    :vertical_label => 'Queue Length' )

        Utils::draw_line( graph,
                          {
                            :label  => 'queue length:',
                            :value  => @disk_io_datasource.queue_length_time,
                            :factor => 1.0 / ( 1000 * 1000 * 1000 ),
                            :color  => '#0000ff',
                            :width  => 1,
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

