# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LinuxDiskIOQueueLength
      include Rocuses
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def template_name()
        return 'linux_disk_io_queue_length'
      end

      def id()
        return sprintf( '%s_%s', template_name, @disk_io_datasource.name )
      end

      def filename()
        return sprintf( '%s_%s', template_name, Rocuses::Utils::escape_for_filename( @disk_io_datasource.name ) )
      end

      def nodenames
        return [ @disk_io_datasource.nodename ]
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

