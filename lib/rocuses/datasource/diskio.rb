# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class DiskIO

      # nodename
      attr_reader :nodename

      # device name
      attr_reader :name

      # read size(byte)
      attr_reader :read_data_size

      # read count
      attr_reader :read_count

      # write size(byte)
      attr_reader :write_data_size

      # write count
      attr_reader :write_count

      # nodename:: nodename
      # name:: device name
      def initialize( nodename, name ) 
        @nodename = nodename
        @name     = name
      end

      def update( config, resource )
        if resource.disk_ios
          resource.disk_ios.each { |disk_io|
            if disk_io.name == @name
              @read_data_size   = create_rrd( config, 'read_data_size' )
              @read_count       = create_rrd( config, 'read_count' )
              @write_data_size  = create_rrd( config, 'write_data_size' )
              @write_count      = create_rrd( config, 'write_count' )

              @read_data_size.update(  disk_io.time, disk_io.read_data_size )
              @read_count.update(      disk_io.time, disk_io.read_count )
              @write_data_size.update( disk_io.time, disk_io.write_data_size )
              @write_count.update(     disk_io.time, disk_io.write_count )
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
                                      :lower_limit => 0,
                                      :upper_limit => 10 * 1000 * 1000 * 1000 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_disk_io_%s_%s',
                        @nodename,
                        @name.gsub( %r{[/ ]}, %q{_} ),
                        type ) 
      end
    end
  end
end
