# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class Traffic
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.3lf %Sbps'

      def initialize( args )
        Rocuses::Utils::check_args( args,
                                    {
                                      :network_interface_datasources => :req,
                                      :name                          => :op,
                                      :nodename                      => :op,
                                    } )
        
        @name                          = args[:name]
        @network_interface_datasources = args[:network_interface_datasources]

        if @name.nil?
          nic_names = Array.new
          @network_interface_datasources.each{ |nic|
            nic_names << nic.name
          }
          @name = nic_names.join( %q{,} )
        end
      end

      def category
        return "Network Interface"
      end

      def name
        return sprintf( 'traffic_%s', @name )
      end

      def nodenames
        nodes = Array.new
        @network_interface_datasources.each { |ds|
          nodes << ds.nodename
        }
        return nodes.uniq
      end

      def description
        title = "Traffic - #{ @name } of #{ nodenames.join( %q{,} ) }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'bits per second',
                                    :rigid          => false )

        inbound_traffic       = RRDTool::RPN_Constant.new( 0 )
        inbound_traffic_avg   = RRDTool::RPN_Constant.new( 0 )
        inbound_traffic_max   = RRDTool::RPN_Constant.new( 0 )
        inbound_traffic_last  = RRDTool::RPN_Constant.new( 0 )
        outbound_traffic      = RRDTool::RPN_Constant.new( 0 )
        outbound_traffic_avg  = RRDTool::RPN_Constant.new( 0 )
        outbound_traffic_max  = RRDTool::RPN_Constant.new( 0 )
        outbound_traffic_last = RRDTool::RPN_Constant.new( 0 )
        @network_interface_datasources.each { |nic|
          inbound_traffic       += RRDTool::RPN_DataSource.new( nic.inbound_data_size, :AVERAGE )
          inbound_traffic_avg   += RRDTool::RPN_DataSource.new( nic.inbound_data_size, :AVERAGE )
          inbound_traffic_max   += RRDTool::RPN_DataSource.new( nic.inbound_data_size, :MAX )
          inbound_traffic_last  += RRDTool::RPN_DataSource.new( nic.inbound_data_size, :LAST )
          outbound_traffic      += RRDTool::RPN_DataSource.new( nic.outbound_data_size, :AVERAGE )
          outbound_traffic_avg  += RRDTool::RPN_DataSource.new( nic.outbound_data_size, :AVERAGE )
          outbound_traffic_max  += RRDTool::RPN_DataSource.new( nic.outbound_data_size, :MAX )
          outbound_traffic_last += RRDTool::RPN_DataSource.new( nic.outbound_data_size, :LAST )
        }
        inbound_traffic       *= 8
        inbound_traffic_avg   *= 8
        inbound_traffic_max   *= 8
        inbound_traffic_last  *= 8
        outbound_traffic      *= 8
        outbound_traffic_avg  *= 8
        outbound_traffic_max  *= 8
        outbound_traffic_last *= 8

        graph.add_item( RRDTool::Area.new( :value => inbound_traffic,
                                           :color => '#00ff00',
                                           :label => "inbound: " ) )
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Last.new( inbound_traffic_last ),
                                             :format => "Current: #{ GPRINT_FORMAT }" ) )
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Average.new( inbound_traffic_avg ),
                                             :format => "Average: #{ GPRINT_FORMAT }" ) )
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Maximum.new( inbound_traffic_last ),
                                             :format => "Maximum: #{ GPRINT_FORMAT }" ) )
        graph.add_item( RRDTool::LineFeed.new( :left ) )

        graph.add_item( RRDTool::Line.new( :value => outbound_traffic,
                                           :width => 1,
                                           :color => '#0000ff',
                                           :label => "outbound:" ) )
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Last.new( outbound_traffic_last ),
                                              :format => "Current: #{ GPRINT_FORMAT }" ) )
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Average.new( outbound_traffic_avg ),
                                              :format => "Average: #{ GPRINT_FORMAT }" ) ) 
        graph.add_item( RRDTool::GPrint.new( :value  => RRDTool::RPN_Maximum.new( outbound_traffic_last ),
                                              :format => "Maximum: #{ GPRINT_FORMAT }" ) )
        graph.add_item( RRDTool::LineFeed.new( :left ) )

        return graph
      end
    end
  end
end

