# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class FilesystemSize
      include Rocuses::GraphTemplate
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.2lf %SB'

      def initialize( filesystem_datasource )
        @filesystem_datasource = filesystem_datasource
      end

      def name
        return sprintf( 'FilesystemSize_%s', escape_name( @filesystem_datasource.mount_point ) )
      end

      def filename
        return sprintf( 'FilesystemSize_%s', escape_name( @filesystem_datasource.mount_point ) )
      end

      def nodenames
        return [ @filesystem_datasource.nodename ]
      end

      def description
        return "Filesystem Size - #{ @filesystem_datasource.mount_point } of #{ @filesystem_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'bytes',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'total: ',
                            :value  => @filesystem_datasource.total_size,
                            :factor => 1,
                            :color  => '#000000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'used:  ',
                            :value  => @filesystem_datasource.used_size,
                            :factor => 1,
                            :stack  => false,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'free:  ',
                            :value  => @filesystem_datasource.free_size,
                            :factor => 1,
                            :stack  => true,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

