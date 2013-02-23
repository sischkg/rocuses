# -*- coding: utf-8 -*-

module Rocuses
  module DataSource
    class NetworkInterface
      include Rocuses

      # nodename
      attr_reader :nodename

      # interface name
      attr_reader :name

      # inbound_packet_count
      attr_reader :inbound_packet_count

      # inbound_data_size(byte)
      attr_reader :inbound_data_size

      # inbound_error_count
      attr_reader :inbound_error_count

      # outbound_packet_count
      attr_reader :outbound_packets_count

      # outbound_data_size(byte)
      attr_reader :outbound_data_size

      # outbound_error_count
      attr_reader :outbound_error_count

      # nodename:: nodename
      # interface_name:: interface name
      def initialize( nodename, interface_name ) 
        @nodename = nodename
        @name     = interface_name
      end

      def update( config, resource )
        if resource.network_interfaces
          resource.network_interfaces.each { |nic|
            if nic.name == @name
              @inbound_packet_count  = create_rrd( config, 'inbound_packet_count' )
              @inbound_data_size     = create_rrd( config, 'inbound_data_size' )
              @inbound_error_count   = create_rrd( config, 'inbound_error_count' )
              @outbound_packet_count = create_rrd( config, 'outbound_packet_count' )
              @outbound_data_size    = create_rrd( config, 'outbound_data_size' )
              @outbound_error_count  = create_rrd( config, 'outbound_error_count' )

              @inbound_packet_count.update(  nic.time, nic.inbound_packet_count )
              @inbound_data_size.update(     nic.time, nic.inbound_data_size )
              @inbound_error_count.update(   nic.time, nic.inbound_error_count )
              @outbound_packet_count.update( nic.time, nic.outbound_packet_count )
              @outbound_data_size.update(    nic.time, nic.outbound_data_size )
              @outbound_error_count.update(  nic.time, nic.outbound_error_count )
            end
          }
        end
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :COUNTER,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_nic_%s_%s',
                        @nodename,
                        Utils::escape_for_filename( @name ),
                        type ) 
      end
    end
  end
end
