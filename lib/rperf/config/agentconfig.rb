# -*- coding: utf-8 -*-

require 'rexml/document'

module RPerf
  module Config

    # Agent 設定管理
    # リソース取得エージェントの設定を管理する
    #
    #  config = RPerf::Config::AgentConfig.new
    #  config.load( File.new( "config.xml" ) )
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

      # bindのrndcのパス
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

        @managers = Array.new
      end


      # 設定XMLファイルをロードする
      # input:: 設定XMLファイルのFileオブジェクトなどのIOオブジェクト
      def load( input )
        doc = REXML::Document.new( input )

        load_manager_hostname( doc )
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
    end
  end
end
