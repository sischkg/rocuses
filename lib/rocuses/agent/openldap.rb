# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'net/ldap'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class OpenLDAP
      include Rocuses
      include Log4r

      def initialize( agentconfig )
        @agentconfig = agentconfig
        @logger      = Logger.new( 'rocuses::agent::openldap' )
      end

      def name
        return "Rocuses::Agent::OpenLDAP"
      end

      GET_RESOURCE_METHOD_OF = {
        :Bind      => :get_openldap_statistics,
      }

      def enable_resource?( type )
        return GET_RESOURCE_METHOD_OF.key?( type.to_sym )
      end

      def list_enable_resources()
        return GET_RESOURCE_METHOD_OF.keys
      end

      # typeで指定したリソースの統計情報を取得し、resourceにその値を追加する
      # typeで指定したリソースを取得できない場合は、ArgumetErrorをraiseする。
      # type:: リソースのタイプ GET_RESOURCE_METHOD_OFのkeyのいずれか
      # resource:: 取得したリソースの統計情報の保存先
      def get_resource( type, resource )
        if ! enable_resource?( type )
          raise ArgumentError.new( "not support type #{type}" )
        end
        send( GET_RESOURCE_METHOD_OF[ type.to_sym ], resource )
      end

      # RETURN:: net/ldapをロード可能である: true
      def self.match_environment?( agentconfig )
        begin

          require 'net/ldap'
          return true
        rescue LoadError => e
          return false
        end
      end

      def get_openldap_statistics( resource )
        args = {
          :hostname      => "localhost",
          :port          => @agentconfig.openldap.port,
          :bind_dn       => @agentconfig.openldap.bind_dn,
          :bind_password => @agentconfig.openldap.bind_password,
        }

        begin
          resource.openldap = get_openldap_monitor_values( args )
          resource.openldap_caches = get_openldap_caches( args )
        rescue => e
        end
      end

      private

      # LDAPサーバをBindし、ブロックを実行する。
      # :hostname:: LDAPサーバ名
      # :port:: LDAPサーバのport
      # :bind_dn:: Bind DN
      # :bind_password:: Bind Password
      #
      #   bind_ldap( :hostname      => 'ldap.example.com',
      #              :port          => 389,
      #              :bind_dn       => 'cn=admin,cn=monitor",
      #              :bind_password => 'secret' ) { |ldap|
      #     ldap.search( :base => 'cn=Operations,cn=monitor',
      #                  :attributes =>  [ 'monitorCounter' ] ) { |entry|
      #       ...
      #     }
      #   }
      #
      def bind_ldap( args )
        require 'net/ldap'
        Utils::check_args( args,
                           {
                             :hostname      => :req,
                             :port          => :req,
                             :bind_dn       => :req,
                             :bind_password => :req,
                           } )
        Net::LDAP.open( :host => args[:hostname],
                        :port => args[:port],
                        :auth => {
                          :method   => :simple,
                          :username => Net::LDAP::DN.escape( args[:bind_dn] ),
                          :password => args[:bind_password],
                        } ) { |ldap|
          yield( ldap )
        }
      end

      # OpenLDAPのcn=monitor以下の統計情報を取得する。
      # ldap:: Net::LDAP
      # dn:: 取得対象のDN
      # attribute:: 取得対象の属性名
      # RETURN:: 統計情報
      def get_openldap_monitor_value( ldap, dn, attribute )
        ldap.search( :base       => dn,
                     :attributes => [ attribute ] ) { |entry|
          next if entry.dn != dn

          entry.each {
            attribute_values = entry[attribute] 
            if attribute_values.size == 1
              return attribute_values[0].to_i
            end
            raise "Cannot #{ dn } counter ( attribute #{ attribute } count is #{ attribute_values.size }"
          }
          raise "Cannot #{ dn } counter ( not found entry )" 
        }
      end

      OPENLDAP_MONITOR_ENTRY_OF= {
        :total_connection      => {
          :dn        => 'cn=Total,cn=Connections,cn=Monitor',
          :attribute => 'monitorCounter',
        },
        :concurrent_connection => {
          :dn        => 'cn=Current,cn=Connections,cn=Monitor',
          :attribute => 'monitorCounter',
        },
        :max_file_descriptor   => {
          :dn        => 'cn=Max File Descriptors,cn=Connections,cn=Monitor',
          :attribute => 'monitorCounter'
        },
        :bind_operation        => {
          :dn        => 'cn=Bind,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :unbind_operation      => {
          :dn        => 'cn=Unbind,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :search_operation      => {
          :dn        => 'cn=Search,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :compare_operation     => {
          :dn        => 'cn=Compare,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :modify_operation      => {
          :dn        => 'cn=Modify,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :modrdn_operation      => {
          :dn        => 'cn=Modrdn,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :add_operation         => {
          :dn        => 'cn=Add,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :delete_operation      => {
          :dn        => 'cn=Delete,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :abandon_operation     => {
          :dn        => 'cn=Abandon,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
        :extended_operation    => {
          :dn        => 'cn=Extended,cn=Operations,cn=Monitor',
          :attribute => 'monitorOpCompleted',
        },
      }

      # OpenLDAPのcn=monitor以下の統計情報を取得する。
      # :hostname:: LDAPサーバ名
      # :port:: LDAPサーバのport
      # :bind_dn:: Bind DN
      # :bind_password:: Bind Password
      # RETURN:: 統計情報Rocuses::Resource::OpenLDAP
      def get_openldap_monitor_values( args )
        openldap_args = Hash.new
        OPENLDAP_MONITOR_ENTRY_OF.each { |key,monitor_entry_info|
          bind_ldap( args ) { |ldap|
            openldap_args[key] = get_openldap_monitor_value( ldap, monitor_entry_info[:dn], monitor_entry_info[:attribute] )
          }
        }
        openldap_args[:time] = Time.now
        return Resource::OpenLDAP.new( openldap_args )
      end

      def get_openldap_caches( args )
        openldap_caches = Array.new
        bind_ldap( args ) { |ldap|
          
          ldap.search( :base       => 'cn=Databases,cn=monitor',
                       :filter     => '(objectClass=olmBDBDatabase)',
                       :attributes => [ 'olmDbDirectory', 'olmBDBentryCache', 'olmBDBIDLCache', 'olmBDBDNCache' ] ) { |entry|
            cache = Resource::OpenLDAPCache.new( :time        => Time.now,
                                                 :directory   => entry['olmDbDirectory'][0].to_s,
                                                 :idl_cache   => entry['olmBDBIDLCache'][0].to_i,
                                                 :entry_cache => entry['olmBDBEntryCache'][0].to_i,
                                                 :dn_cache    => entry['olmBDBDNCache'][0].to_i )
            openldap_caches.push( cache )
          }
        }
        return openldap_caches
      end

    end
  end
end

