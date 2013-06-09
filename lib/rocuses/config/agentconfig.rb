# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rocuses/config/default'

module Rocuses
  module Config

    # Agent 設定管理
    # リソース取得エージェントの設定を管理する
    #
    #  config = Rocuses::Config::AgentConfig.new
    #  config.load( File.new( "agentconfig.xml" ) )
    #
    #  bind_address = config.bind_address
    #  bind_port    = config.bind_port
    #  user         = config.user
    #  group        = config.group
    #  managers     = config.managers
    #
    #  rndc        = config.rndc_path        # "/usr/local/bind/sbin/rndc"
    #  mailq       = config.mailq_path       # "/usr/local/postfix/bin/mailq"
    #  mta_tyoe    = config.mta_type         # "postfix"
    #  named_stats = config.named_stats_path # "/var/named/named.stats"
    #
    # 設定XMLサンプル
    # <rocuses>
    #   <agent>
    #     <manager hostname="manager1.in.example.com"/>
    #     <manager hostname="192.168.0.1"/>
    #     <bind address="192.168.0.100" port="20080"/>
    #     <user name="rocus"/>
    #     <group name="rocus"/>
    #     <options>
    #       <rndc path="/usr/local/bind/sbin/rndc"/>
    #       <named_stats path="/var/named/named.stats"/>
    #       <mta type="postfix"/>
    #       <mailq path="/usr/local/postfix/bin/mailq"/>
    #       <openldap port="389" bind_dn="cn=admin,cn=monitor" bind_password="pass"/>
    #     </options>
    #   </agent>
    # </rocuses>
    #
    class AgentConfig
      # ManagerのhostnameのArray
      attr_reader :managers

      # bindするIP address
      attr_reader :bind_address

      # bindするport
      attr_reader :bind_port

      # username of agent euid
      attr_reader :user

      # group of agent egid
      attr_reader :group

      # BINDのrndcのパス
      attr_reader :rndc_path

      # bindのstatistics-fileのパス
      attr_reader :named_stats_path

      # mta の種類 :postfix or :sendmail
      attr_reader :mta_type

      # mailqのパス
      attr_reader :mailq_path

      # OpenLDAPのポート
      attr_reader :openldap_port

      # OpenLDAPのmonitorデータベースの値を取得するためのBind DN
      attr_reader :openldap_bind_dn

      # OpenLDAPのmonitorデータベースの値を取得するためのBindパスワード
      attr_reader :openldap_bind_password

      #
      def initialize
        # default values.
        @rndc_path        = '/usr/sbin/rndc'
        @named_stats_path = '/var/named/named.stats'
        @mta_type         = 'sendmail'
        @mailq_path       = '/usr/bin/mailq'
        @openldap_port    = 389
        @openldap_bind_dn = 'cn=admin,cn=monitor'
        @openldap_bind_password = 'password'
        @bind_address     = Rocuses::Config::Default::BIND_ADDRESS
        @bind_port        = Rocuses::Config::Default::BIND_PORT
        @user             = Rocuses::Config::Default::AGENT_USER
        @group            = Rocuses::Config::Default::AGENT_GROUP
        @managers         = Array.new
      end


      # 設定XMLファイルをロードする
      # input:: 設定XMLファイルのFileオブジェクトなどのIOオブジェクト
      def load( input )
        doc = REXML::Document.new( input )

        load_manager_hostname( doc )
        load_bind_address( doc )
        @user  = load_id( doc, 'user',  @user )
        @group = load_id( doc, 'group', @group )

        @rndc_path   = load_option( doc, 'rndc',        'path', @rndc_path )
        @named_stats = load_option( doc, 'named_stats', 'path', @named_stats )
        @mta_type    = load_option( doc, 'mta',         'type', @mta_type )
        @mailq_path  = load_option( doc, 'mailq',       'path', @mailq_path )
        @openldap_port          = load_option( doc, 'openldap', 'port',          @openldap_port ).to_i
        @openldap_bind_dn       = load_option( doc, 'openldap', 'bind_dn',       @openldap_bind_dn )
        @openldap_bind_password = load_option( doc, 'openldap', 'bind_password', @openldap_bind_password )
      end

      private

      # <rocuses><agent><options><NAME ATTR="VAR"/></options></agent></rocuses>
      # のVARを取得する。
      # doc:: REXML::Document
      # name:: Elementの名前
      # attr:: 属性の名前
      # default_value:: Elementまたは、attributeが存在しない場合の既定値
      def load_option( doc, name, attr, default_value )
        element = doc.elements["/rocuses/agent/options/#{ name }"]
        if element.nil? || ! element.attributes.key?( attr )
          return default_value
        end
        return element.attributes[attr]
      end

      # <rocuses><agent><manager hostname="HOSTNAME"/></agent></rocuses>
      # HOSTNAMEを取得する
      # doc:: REXML::Document
      def load_manager_hostname( doc )
        doc.elements.each( "/rocuses/agent/manager" ) { |element|
          manager = element.attributes[ "hostname" ]
          if manager.nil?
            raise "<manager/> must has hostname attribute"
          end
          @managers.push( manager )
        }
      end

      # <rocuses><agent><bind address="ADDRESS" port="PORT"/></agent></rocuses>
      # BINDするIP AddressとPortを取得する
      # doc:: REXML::Document
      def load_bind_address( doc )
        doc.elements.each( "/rocuses/agent/bind" ) { |element|
          @bind_address = element.attributes[ "address" ]
          @bind_port = element.attributes[ "port" ]
          if @bind_address.nil?
            @bind_address = DEFAULT_BIND_ADDRESS
          end
          if @bind_port.nil?
            @bind_port = DEFAULT_BIND_PORT
          end
        }
      end

      # <rocuses><agent><(user|group) name="Agent E(U|G)ID"/></agent></rocuses>
      # Agentのeuid/guidを取得する
      # doc:: REXML::Document
      # path:: "user" or "group"
      # default_id:: defaut値
      def load_id( doc, path, default_id )
        doc.elements.each( "/rocuses/agent/#{ path }" ) { |element|
          id = element.attributes[ "name" ]
          if id
            return id
          end
        }
        return default_id
      end

    end
  end
end
