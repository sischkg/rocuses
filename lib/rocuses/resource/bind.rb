# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # BIND統計情報を保持するクラス
    class Bind
      include Rocuses
      include Comparable

      # データ取得時刻
      attr_reader :time

      # 受信したrequestの数
      attr_reader :request_ipv4

      # 受信したEDNS0 requestの数
      attr_reader :request_edns0

      # 受信したTCP requestの数
      attr_reader :request_tcp

      # 再起問い合わせを拒否した数
      attr_reader :rejected_recursive_request

      # 応答した数
      attr_reader :response

      # EDNSで応答した数
      attr_reader :response_edns0

      # success を応答した数
      attr_reader :success

      # authorative_answerで応答した数
      attr_reader :authorative_answer

      # non_authorative_answerで応答した数
      attr_reader :non_authorative_answer

      # nxrrsetを応答した数
      attr_reader :nxrrset

      # servfailを応答した数
      attr_reader :servfail

      # nxdomainを応答した数
      attr_reader :nxdomain

      # 再起問い合わせを実行した回数
      attr_reader :recursion

      # incoming queriesの内訳
      attr_reader :incoming_queries_of

      # outgoing queriesの内訳
      attr_reader :outgoing_queries_of

      # Socket IO
      attr_reader :socket_io_statistics_of

      # ::time データ取得時刻
      # ::request 受信したrequestの数
      # ::request_ends0 受信したEDNS0 requestの数
      # ::request_tcp 受信したTCP requestの数
      # ::rejected_recursive_request 再起問い合わせを拒否した数
      # ::response 応答した数
      # ::response_ends0 EDNS0で応答した数
      # ::sucess success を応答した数
      # ::authorative_answer Authorative Answerで応答した数
      # ::non_authorative_answer Non Authorative Answerで応答した数
      # ::nxrrset nxrrsetを応答した数
      # ::servfail servfailを応答した数
      # ::nxdomain nxdomainを応答した数
      # ::recursion 再起問い合わせを実行した回数
      # ::incoming_queries_of 受信したQueryの内訳
      # ::outgoing_queries_of 送信したQueryの内訳
      # ::socket_io_statistics_of SocketのI/O情報
      def initialize( args )
        args = Utils::check_args( args,
                                  {
                                    :time                        => :req,
                                    :request_ipv4                => :op,
                                    :request_edns0               => :op,
                                    :request_tcp                 => :op,
                                    :rejected_recursive_request  => :op,
                                    :response                    => :op,
                                    :response_edns0              => :op,
                                    :success                     => :op,
                                    :authorative_answer          => :op,
                                    :non_authorative_answer      => :op,
                                    :nxrrset                     => :op,
                                    :servfail                    => :op,
                                    :nxdomain                    => :op,
                                    :recursion                   => :op,
                                    :incoming_queries_of         => :op,
                                    :outgoing_queries_of         => :op,
                                    :socket_io_statistics_of     => :op,
                                  },
                                  {
                                    :request_ipv4                => 0,
                                    :request_edns0               => 0,
                                    :request_tcp                 => 0,
                                    :rejected_recursive_request  => 0,
                                    :response                    => 0,
                                    :response_edns0              => 0,
                                    :success                     => 0,
                                    :authorative_answer          => 0,
                                    :non_authorative_answer      => 0,
                                    :nxrrset                     => 0,
                                    :servfail                    => 0,
                                    :nxdomain                    => 0,
                                    :recursion                   => 0,
                                    :incoming_queries_of         => [],
                                    :outgoing_queries_of         => [],
                                    :socket_io_statistics_of     => [],
                                  })

        @time                       = args[:time]
        @request_ipv4               = args[:request_ipv4]
        @request_edns0              = args[:request_edns0]
        @request_tcp                = args[:request_tcp]
        @rejected_recursive_request = args[:rejected_recursive_request]
        @response                   = args[:response]
        @response_edns0             = args[:response_edns0]
        @success                    = args[:success]
        @authorative_answer         = args[:authorative_answer]
        @non_authorative_answer     = args[:non_authorative_answer]
        @nxrrset                    = args[:nxrrset]
        @servfail                   = args[:servfail]
        @nxdomain                   = args[:nxdomain]
        @recursion                  = args[:recursion]
        @incoming_queries_of        = args[:incoming_queries_of]
        @outgoing_queries_of        = args[:outgoing_queries_of]
        @socket_io_statistics_of    = args[:socket_io_statistics_of]
      end

    end
  end
end

