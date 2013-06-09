# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate

    class CPU
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GRPINT_FORMAT = '%5.2lf %%'

      def initialize( cpu_datasources )
        @cpu_datasources = cpu_datasources
      end

      def name
        return 'CPU'
      end

      def nodenames
        nodes = Array.new
        @cpu_datasources.each { |ds|
          nodes << ds.nodename
        }
        return nodes.uniq
      end

      def description
        return "CPU - #{ nodenames.join( %q{,} ) }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :upper_limit    => 100,
                                    :lower_limit    => 0,
                                    :vertical_label => 'percent',
                                    :rigid          => true )

        @cpu_datasources.each { |cpu|
          cpu_usage =
          ( RRDTool::RPN_DataSource.new( cpu.user,   :AVERAGE ) +
            RRDTool::RPN_DataSource.new( cpu.system, :AVERAGE ) +
            RRDTool::RPN_DataSource.new( cpu.wait,   :AVERAGE ) ) * 100

          cpu_usage_avg =
          ( RRDTool::RPN_DataSource.new( cpu.user,   :AVERAGE ) +
            RRDTool::RPN_DataSource.new( cpu.system, :AVERAGE ) +
            RRDTool::RPN_DataSource.new( cpu.wait,   :AVERAGE ) ) * 100

          cpu_usage_max =
          ( RRDTool::RPN_DataSource.new( cpu.user,   :MAX ) +
            RRDTool::RPN_DataSource.new( cpu.system, :MAX ) +
            RRDTool::RPN_DataSource.new( cpu.wait,   :MAX ) ) * 100

          cpu_usage_last =
          ( RRDTool::RPN_DataSource.new( cpu.user,   :LAST ) +
            RRDTool::RPN_DataSource.new( cpu.system, :LAST ) +
            RRDTool::RPN_DataSource.new( cpu.wait,   :LAST ) ) * 100
          
          graph.add_item( RRDTool::Line.new( :value => cpu_usage,
                                             :width => 1,
                                             :color => '#000000',
                                             :label => "#{ cpu.name }: " ) )
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Last.new( cpu_usage_last ),
                                               :format => "Current: #{ GRPINT_FORMAT }" ) )
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Average.new( cpu_usage_avg ),
                                               :format => "Average: #{ GRPINT_FORMAT }" ) )
          graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Maximum.new( cpu_usage_max ),
                                               :format => "Maximum: #{ GRPINT_FORMAT }" ) )

          graph.add_item( RRDTool::LineFeed.new( :left ) )
        }

        return graph
      end
    end
  end
end

