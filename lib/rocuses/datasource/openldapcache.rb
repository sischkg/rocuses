# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class OpenLDAPCache
      include Rocuses

      # nodename
      attr_reader :nodename

      # database directory
      attr_reader :directory

      # IDL Cache数
      attr_reader :idl_cache

      # Entry Cache数
      attr_reader :entry_cache

      # DN Cache数
      attr_reader :dn_cache

      # nodename:: nodename
      def initialize( nodename, directory )
        @nodename  = nodename
        @directory = directory
      end

      def update( config, resource )
        @idl_cache   = create_rrd( config, 'idl_cache' )
        @entry_cache = create_rrd( config, 'entry_cache' )
        @dn_cache    = create_rrd( config, 'dn_cache' )

        if resource.openldap_caches
          resource.openldap_caches.each { |cache|
            if cache.directory == @directory
              @idl_cache.  update( cache.time, cache.idl_cache )
              @entry_cache.update( cache.time, cache.entry_cache )
              @dn_cache.   update( cache.time, cache.dn_cache )
            end
          }
        end
      end

      private

      def create_rrd( config, name )
        ds = RRDTool::DataSource.new( :name        => datasource_name( name ),
                                      :type        => :GAUGE,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( name )
        return sprintf( '%s_openldap_cache_%s_%s',
                        @nodename,
                        Rocuses::Utils::escape_name( @directory ),
                        name )
      end
    end
  end
end
