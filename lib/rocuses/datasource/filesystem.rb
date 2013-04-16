# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class Filesystem

      # nodename
      attr_reader :nodename

      # mount point
      attr_reader :mount_point

      # Total Size(byte)
      attr_reader :total_size

      # Used Size(byte)
      attr_reader :used_size

      # Free Size(byte)
      attr_reader :free_size

      # Total Files
      attr_reader :total_files

      # Used FIles
      attr_reader :used_files

      # nodename:: nodename
      # mount_point:: mount point
      def initialize( nodename, mount_point ) 
        @nodename    = nodename
        @mount_point = mount_point
      end

      def update( config, resource )
        if resource.filesystems
          resource.filesystems.each { |filesystem|
            if filesystem.mount_point == @mount_point
              @total_size  = create_rrd( config, 'total_size' )
              @used_size   = create_rrd( config, 'used_size' )
              @free_size   = create_rrd( config, 'free_size' )
              @total_files = create_rrd( config, 'total_files' )
              @used_files  = create_rrd( config, 'used_files' )

              @total_size.update(  filesystem.time, filesystem.total_size )
              @used_size.update(   filesystem.time, filesystem.used_size )
              @free_size.update(   filesystem.time, filesystem.free_size )
              @total_files.update( filesystem.time, filesystem.total_files )
              @used_files.update(  filesystem.time, filesystem.used_files )
            end
          }
        end
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :GAUGE,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_filesytem_%s_%s',
                        @nodename,
                        @mount_point.gsub( %r{[/ ]}, %q{_} ),
                        type ) 
      end
    end
  end
end
