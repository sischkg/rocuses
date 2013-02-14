# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class CPUAverage
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.2lf %%'

      def initialize( cpu_datasource )
        @cpu_datasource = cpu_datasource
      end

      def name
        return 'CPU_Average'
      end

      def filename
        return 'CPU_Average'
      end

      def make_graph()
        title = "CPU - #{ @cpu_datasource.nodename }"

        graph = RRDTool::Graph.new( :title       => title,
                                    :upper_limit => 100 * @cpu_datasource.cpu_count,
                                    :lower_limit => 0,
                                    :rigid       => true )

        Utils::draw_area( graph,
                          {
                            :label  => 'user  ',
                            :value  => @cpu_datasource.user,
                            :factor => 100,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'system',
                            :value  => @cpu_datasource.system,
                            :factor => 100,
                            :stack  => true,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'wait  ',
                            :value  => @cpu_datasource.wait,
                            :factor => 100,
                            :stack  => true,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

