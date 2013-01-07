# -*- coding: utf-8 -*-

require 'rrdtool/rpn'
require 'rrdtool/graph'
require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class CPUAverage
      include Rocuses::GraphTemplate

      GPRINT_FORMAT = '%5.2lf %%'

      def initialize( cpu_datasource )
        @cpu_datasource = cpu_datasource
      end

      def draw( config, begin_time, end_time )
        graph = RRDTool::Graph.new

        Utils::draw_line( graph,
                          {
                            :label  => 'user  ',
                            :value  => @cpu_datasource.user,
                            :width  => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'system',
                            :value  => @cpu_datasource.system,
                            :width  => 1,
                            :stack  => true,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'wait  ',
                            :value  => @cpu_datasource.wait,
                            :width  => 1,
                            :stack  => true,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        
        title = "CPU - #{ @cpu_datasource.nodename }"
        return graph.draw( :title       => title,
                           :width       => config.image_width,
                           :height      => config.image_height,
                           :upper_limit => 100,
                           :lower_limit => 0 )
      end
    end
  end
end

