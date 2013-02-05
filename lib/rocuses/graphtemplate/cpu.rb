# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'

module Rocuses
  module GraphTemplate

    class CPU
      include Rocuses::GraphTemplate

      GRPINT_FORMAT = '%5.2lf %%'

      def initialize( cpu_datasources )
        @cpu_datasources = cpu_datasources
      end

      def name
        return 'CPU'
      end

      def make_graph()
        if @cpu_datasources.size <= 0
          return nil
        end

        title = "CPU - #{ @cpu_datasources[0].nodename }"
        graph = RRDTool::Graph.new( :title       => title,
                                    :upper_limit => @cpu_datasources.size,
                                    :lower_limit => 0 )

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
                                             :label => cpu.name ) )
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

