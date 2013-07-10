# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class OpenLDAP

      # nodename
      attr_reader :nodename

      # 起動してからの接続数
      attr_reader :total_connection

      # 同時接続数
      attr_reader :concurrent_connection

      # MAX File Descriptor
      attr_reader :max_file_descriptor

      # bind operation
      attr_reader :bind_operation

      # unbind operation
      attr_reader :unbind_operation

      # search operation
      attr_reader :search_operation

      # comapre operation
      attr_reader :compare_operation

      # modify operation
      attr_reader :modify_operation

      # modrdn operation
      attr_reader :modrdn_operation

      # add operation
      attr_reader :add_operation

      # delete operation
      attr_reader :delete_operation

      # abandon operation
      attr_reader :abandon_operation

      # extended operation
      attr_reader :extended_operation

      # nodename:: nodename
      def initialize( nodename )
        @nodename = nodename
      end

      def update( config, resource )
        if resource.openldap
          @total_connection      = create_rrd( config, 'total_connection' )
          @concurrent_connection = create_rrd( config, 'concurrent_connection', :GAUGE )
          @max_file_descriptor   = create_rrd( config, 'max_file_descriptor',   :GAUGE )
          @bind_operation        = create_rrd( config, 'bind_operation' )
          @unbind_operation      = create_rrd( config, 'unbind_operation' )
          @search_operation      = create_rrd( config, 'search_operation' )
          @compare_operation     = create_rrd( config, 'compare_operation' )
          @modify_operation      = create_rrd( config, 'modify_operation' )
          @modrdn_operation      = create_rrd( config, 'modrdn_operation' )
          @add_operation         = create_rrd( config, 'add_operation' )
          @delete_operation      = create_rrd( config, 'delete_operation' )
          @abandon_operation     = create_rrd( config, 'abandon_operation' )
          @extended_operation    = create_rrd( config, 'extended_operation' )

          @total_connection.     update( resource.openldap.time, resource.openldap.total_connection )
          @concurrent_connection.update( resource.openldap.time, resource.openldap.concurrent_connection )
          @max_file_descriptor.  update( resource.openldap.time, resource.openldap.max_file_descriptor )
          @bind_operation.       update( resource.openldap.time, resource.openldap.bind_operation )
          @unbind_operation.     update( resource.openldap.time, resource.openldap.unbind_operation )
          @search_operation.     update( resource.openldap.time, resource.openldap.search_operation )
          @compare_operation.    update( resource.openldap.time, resource.openldap.compare_operation )
          @modify_operation.     update( resource.openldap.time, resource.openldap.modify_operation )
          @modrdn_operation.     update( resource.openldap.time, resource.openldap.modrdn_operation )
          @add_operation.        update( resource.openldap.time, resource.openldap.add_operation )
          @delete_operation.     update( resource.openldap.time, resource.openldap.delete_operation )
          @abandon_operation.    update( resource.openldap.time, resource.openldap.abandon_operation )
          @extended_operation.   update( resource.openldap.time, resource.openldap.extended_operation )
        end
      end

      private

      def create_rrd( config, name, ds_type = :COUNTER )
        ds = RRDTool::DataSource.new( :name        => datasource_name( name ),
                                      :type        => ds_type,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_openldap_%s', @nodename, type )
      end
    end
  end
end
