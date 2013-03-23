# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class FilesystemFiles
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%10.0lf'

      def initialize( filesystem_datasource )
        @filesystem_datasource = filesystem_datasource
      end

      def name
        return 'FilesystemFiles'
      end

      def filename
        return sprintf( 'FilesystemFiles_%s', @filesystem_datasource.mount_point.gsub( %r{[/ ]}, %q{_} ) )
      end

      def nodenames
        return [ @filesystem_datasource.nodename ]
      end

      def make_graph()
        title = "Filesystem i-node - #{ @filesystem_datasource.mount_point } of #{ @filesystem_datasource.nodename }"

        graph = RRDTool::Graph.new( :title       => title,
                                    :lower_limit => 0,
                                    :rigid       => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'total: ',
                            :value  => @filesystem_datasource.total_files,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'used:  ',
                            :value  => @filesystem_datasource.used_files,
                            :factor => 1,
                            :stack  => false,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end

