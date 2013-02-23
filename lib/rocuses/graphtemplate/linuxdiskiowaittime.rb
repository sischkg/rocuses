# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class LinuxDiskIOWaitTime
      include Rocuses
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def template_name()
        return 'linux_disk_io_wait_time'
      end

      def id()
        return sprintf( '%s_%s', template_name, @disk_io_datasource.name )
      end

      def filename()
        return sprintf( '%s_%s', template_name, Rocuses::Utils::escape_for_filename( @disk_io_datasource.name ) )
      end

      def make_graph()
        title = "Disk IO Wait Time - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
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

