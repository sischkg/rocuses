# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rocuses/config/default'

module Rocuses
  module Config

    class Named
      attr_reader :address

      attr_reader :port

      attr_reader :rndc_path

      attr_reader :stats_path

      def initialize( args )
        @address    = args[:address]
        @port       = args[:port]
        @rndc_path  = args[:rndc_path]
        @stats_path = args[:stats_path]
      end
    end

    class OpenLDAP
      attr_reader :address

      attr_reader :port

      attr_reader :bind_dn

      attr_reader :bind_password

      def initialize( args )
        @address       = args[:address]
        @port          = args[:port]
        @bind_dn       = args[:bind_dn]
        @bind_password = args[:bind_password]
      end
    end

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
    #  mailq       = config.mailq_path       # "/usr/local/postfix/bin/mailq"
    #  mta_tyoe    = config.mta_type         # "postfix"
    #
    #  named_config = config.named
    #  openldap_config = config.openldap
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
    #       <mta type="postfix"/>
    #       <mailq path="/usr/local/postfix/bin/mailq"/>
    #       <openldap address="127.0.0.1" port="389" bind_dn="cn=admin,cn=monitor" bind_password="pass"/>
    #       <named address="192.168.0.100" port="10053"/>
    #       <!- <named rndc_path="/usr/sbin/rndc" stats_path="/var/named/named.stats"/> ->
    #     </options>
    #   </agent>
    # </rocuses>
    #
    class AgentConfig
      include Rocuses::Config::Default

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

      # mta の種類 :postfix or :sendmail
      attr_reader :mta_type

      # mailqのパス
      attr_reader :mailq_path

      # OpenLDAPの設定
      attr_reader :openldap

      # Bindの設定
      attr_reader :named

      #
      def initialize
        # default values.
        @mta_type         = 'sendmail'
        @mailq_path       = '/usr/bin/mailq'
        @bind_address     = BIND_ADDRESS
        @bind_port        = BIND_PORT
        @user             = AGENT_USER
        @group            = AGENT_GROUP
        @managers         = Array.new
        @named            = Named.new( :address    => NAMED_STATISTICS_CHANNEL_ADDRESS,
                                       :port       => NAMED_STATISTICS_CHANNEL_PORT,
                                       :rndc_path  => NAMED_RNDC_PATH,
                                       :stats_path => NAMED_STATS_PATH )
        @openldap         = OpenLDAP.new( :address       => OPENLDAP_ADDRESS,
                                          :port          => OPENLDAP_PORT,
                                          :bind_dn       => OPENLDAP_BIND_DN,
                                          :bind_password => OPENLDAP_BIND_PASSWORD )
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

        @openldap = OpenLDAP.new( :address       => load_option( doc, 'openldap', 'address',       @openldap.address ),
                                  :port          => load_option( doc, 'openldap', 'port',          @openldap.port ).to_i,
                                  :bind_dn       => load_option( doc, 'openldap', 'bind_dn',       @openldap.bind_dn ),
                                  :bind_password => load_option( doc, 'openldap', 'bind_password', @openldap.bind_password ) )

        @named = Named.new( :address    => load_option( doc, 'named', 'address',    @named.address ),
                            :port       => load_option( doc, 'named', 'port',       @named.port ).to_i,
                            :rndc_path  => load_option( doc, 'named', 'rndc_path',  @named.rndc_path ),
                            :stats_path => load_option( doc, 'named', 'stats_path', @named.stats_path ) )
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
