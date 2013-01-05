# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rperf/config/default'

module RPerf
  module Config

    # Agent 設定管理
    # リソース取得エージェントの設定を管理する
    #
    #  config = RPerf::Config::AgentConfig.new
    #  config.load( File.new( "agentconfig.xml" ) )
    #  rndc = config.rndc_path    # "/usr/local/bind/sbin/rndc"
    #  mailq = config.mailq_path  # "/usr/local/postfix/bin/mailq"
    #  mta_tyoe = config.mta_type # "postfix"
    #  named_stats = config.named_stats_path # "/var/named/named.stats"
    #
    # 設定XMLサンプル
    # <rperf>
    #   <agent>
    #     <manager hostname="manager1.in.example.com"/>
    #     <manager hostname="192.168.0.1"/>
    #     <bind address="192.168.0.100" port="20080"/>
    #     <options>
    #       <rndc path="/usr/local/bind/sbin/rndc"/>
    #       <named_stats path="/var/named/named.stats"/>
    #       <mta type="postfix"/>
    #       <mailq path="/usr/local/postfix/bin/mailq"/>
    #     </options>
    #   </agent>
    # </rperf>
    #
    class AgentConfig
      # ManagerのhostnameのArray
      attr_reader :managers

      # bindするIP address
      attr_reader :bind_address

      # bindするport
      attr_reader :bind_port

      # BINDのrndcのパス
      attr_reader :rndc_path

      # bindのstatistics-fileのパス
      attr_reader :named_stats_path

      # mta の種類 :postfix or :sendmail
      attr_reader :mta_type

      # mailqのパス
      attr_reader :mailq_path

      #
      def initialize
        # default values.
        @rndc_path        = '/usr/sbin/rndc'
        @named_stats_path = '/var/named/named.stats'
        @mta_type         = 'sendmail'
        @mailq_path       = '/usr/bin/mailq'
        @bind_address     = RPerf::Config::Default::BIND_ADDRESS
        @bind_port        = RPerf::Config::Default::BIND_PORT
        @managers         = Array.new
      end


      # 設定XMLファイルをロードする
      # input:: 設定XMLファイルのFileオブジェクトなどのIOオブジェクト
      def load( input )
        doc = REXML::Document.new( input )

        load_manager_hostname( doc )
        load_bind_address( doc )
        @rndc_path   = load_option( doc, 'rndc',        'path', @rndc_path )
        @named_stats = load_option( doc, 'named_stats', 'path', @named_stats )
        @mta_type    = load_option( doc, 'mta',         'type', @mta_type )
        @mailq_path  = load_option( doc, 'mailq',       'path', @mailq_path )
      end

      private

      # <rperf><agent><options><NAME ATTR="VAR"/></options></agent></rperf>
      # のVARを取得する。
      # doc:: REXML::Document
      # name:: Elementの名前
      # attr:: 属性の名前
      # default_value:: Elementまたは、attributeが存在しない場合の既定値
      def load_option( doc, name, attr, default_value )
        element = doc.elements["//rperf/agent/options/#{ name }"]
        if element.nil? || ! element.attributes.key?( attr )
          return default_value
        end
        return element.attributes[attr]
      end

      # <rperf><agent><manager hostname="HOSTNAME"/></agent></rperf>
      # HOSTNAMEを取得する
      # doc:: REXML::Document
      def load_manager_hostname( doc )
        doc.elements.each( "//rperf/agent/manager" ) { |element|
          manager = element.attributes[ "hostname" ]
          if manager.nil?
            raise "<manager/> must has hostname attribute"
          end
          @managers.push( manager )
        }
      end

      # <rperf><agent><bind address="ADDRESS" port="PORT"/></agent></rperf>
      # BINDするIP AddressとPortを取得する
      # doc:: REXML::Document
      def load_bind_address( doc )
        doc.elements.each( "//rperf/agent/bind" ) { |element|
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

    end
  end
end
