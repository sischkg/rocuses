# -*- coding: utf-8 -*-

require 'rocuses/graphtemplate/utils'

module Rocuses
  module GraphTemplate
    class Traffic
      include Rocuses
      include Rocuses::GraphTemplate

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
        @nodename                      = args[:nodename]

        if @name.nil?
          nic_names = Array.new
          @network_interface_datasources.each{ |nic|
            nic_names << nic.name
          }
          @name = nic_names.join( %q{,} )
        end

        if @nodename.nil?
          if @network_interface_datasources.size > 0
            @nodename = @network_interface_datasources[0].nodename
          else
            @nodename = %q{}
          end
        end
      end

      def template_name()
        return 'Traffic'
      end

      def id()
        return sprintf( '%s_%s', template_name, @name )
      end

      def filename()
        return sprintf( '%s_%s', template_name, Rocuses::Utils::escape_for_filename( @name ) )
      end

      def make_graph()
        title = "Traffic - #{ @name } of #{ @nodename }"

        graph = RRDTool::Graph.new( :title          => title,
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

