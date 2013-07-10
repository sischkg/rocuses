# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class LinuxDiskIO

      # nodename
      attr_reader :nodename

      # device name
      attr_reader :name

      # Queueが空でない時間(nanosecond)
      attr_reader :wait_time

      # Queue内のIO Requestの数と経過時間の積の和(n * nanosecond)
      attr_reader :queue_length_time

      # name:: デバイス名
      def initialize( nodename, name ) 
        @nodename = nodename
        @name     = name
      end

      def update( config, resource )
        if resource.linux_disk_ios
          resource.linux_disk_ios.each { |disk_io|
            if disk_io.name == @name
              @wait_time         = create_rrd( config, 'wait_time' )
              @queue_length_time = create_rrd( config, 'queue_length_time' )

              @wait_time.update(         disk_io.time, disk_io.wait_time )
              @queue_length_time.update( disk_io.time, disk_io.queue_length_time )
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
        return sprintf( '%s_linux_disk_io_%s_%s',
                        @nodename,
                        Rocuses::Utils::escape_name( @name ),
                        type ) 
      end
    end
  end
end
