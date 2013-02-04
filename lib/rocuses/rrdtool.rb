# -*- coding: utf-8 -*-

require 'rocuses/utils'
require 'rocuses/rrdtool/datasource'
require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/rrdtool/rrdtoolimp'

module Rocuses
  module RRDTool

    module_function

    def set_parameters( args )
      RRDTool::RRDToolImp.instance.set_parameters( args )
    end

    def rrd_filename( datasource )
      RRDTool::RRDToolImp.instance.rrd_filename( datasource )    
    end
    
    def create( cmd )
      RRDTool::RRDToolImp.instance.create( cmd )
    end

    def update( cmd )
      RRDTool::RRDToolImp.instance.update( cmd )
    end

    def draw( cmd )
      RRDTool::RRDToolImp.instance.draw( cmd )
    end

    def assign_name()
      RRDTool::RRDToolImp.instance.assign_name()
    end

    def close()
      RRDTool::RRDToolImp.instance.close()
    end

  end
end
