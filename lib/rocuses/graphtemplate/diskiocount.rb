# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class DiskIOCount
      include Rocuses
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def template_name()
        return 'DiskIOCount'
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
        title = "Disk IO Count - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
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

