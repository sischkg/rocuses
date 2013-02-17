# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class DiskIOSize
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.3lf'

      def initialize( disk_io_datasource )
        @disk_io_datasource = disk_io_datasource
      end

      def name
        return 'disk_io_size'
      end

      def filename
        return sprintf( 'disk_io_size_%s', @disk_io_datasource.name.gsub( %r{[/ ]}, %q{_} ) )
      end

      def make_graph()
        title = "Disk IO Size - #{ @disk_io_datasource.name } of #{ @disk_io_datasource.nodename }"

        graph = RRDTool::Graph.new( :title          => title,
                                    :lower_limit    => 0,
                                    :upper_limit    => 10 * 000 * 000 * 000,
                                    :rigid          => false,
                                    :vertical_label => "bits per second" )

        Utils::draw_area( graph,
                          {
                            :label  => 'read: ',
                            :value  => @disk_io_datasource.read_data_size,
                            :factor => 8,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'write:',
                            :value  => @disk_io_datasource.write_data_size,
                            :factor => 8,
                            :width  => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

