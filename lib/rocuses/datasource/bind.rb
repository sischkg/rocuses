# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/rrdtool/datasource'

module Rocuses
  module DataSource

    class Binf

      # nodename
      attr_reader :nodename

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

      # nodename:: nodename
      def initialize( nodename )
        @nodename = nodename
      end

      def update( config, resource )
        if resource.bind
          @request_ipv4               = create_rrd( config, 'request_ipv4' )
          @request_edns0              = create_rrd( config, 'request_edns' )
          @request_tcp                = create_rrd( config, 'request_tcp' )
          @rejected_recursive_request = create_rrd( config, 'rejected_recursive_request' )
          @response                   = create_rrd( config, 'response' )
          @response_edns0             = create_rrd( config, 'response_edns' )
          @success                    = create_rrd( config, 'success' )
          @authorative_answer         = create_rrd( config, 'authorative_answer' )
          @non_authorative_answer     = create_rrd( config, 'non_authorative_answer' )
          @nxrrset                    = create_rrd( config, 'nxrrset' )
          @servfail                   = create_rrd( config, 'servfail' )
          @nxdomain                   = create_rrd( config, 'nxdomain' )
          @recursion                  = create_rrd( config, 'reciursion' )

          @request_ipv4.              update( resource.time, resource.bind.request_ipv4 )
          @request_edns0.             update( resource.time, resource.bind.request_edns0 )
          @request_tcp.               update( resource.time, resource.bind.request_tcp )
          @rejected_recursive_request.update( resource.time, resource.bind.rejected_recursive_request )
          @response.                  update( resource.time, resource.bind.response )
          @response_edns0.            update( resource.time, resource.bind.response_edns0 )
          @success.                   update( resource.time, resource.bind.success )
          @authorative_answer.        update( resource.time, resource.bind.authorative_answer )
          @non_authorative_answer.    update( resource.time, resource.bind.non_authorative_answer )
          @nxrrset.                   update( resource.time, resource.bind.nxrrset )
          @servfail.                  update( resource.time, resource.bind.servfail )
          @nxdomain.                  update( resource.time, resource.bind.nxdomain )
          @recursion.                 update( resource.time, resource.bind.recursion )
        end
      end

      private

      def create_rrd( config, type )
        ds = RRDTool::DataSource.new( :name        => datasource_name( type ),
                                      :type        => :COUNTER,
                                      :step        => config.step,
                                      :heartbeat   => config.heartbeat,
                                      :lower_limit => 0 )
        ds.create
        return ds
      end

      def datasource_name( type )
        return sprintf( '%s_bind_%s', @nodename, type )
      end
    end
  end
end
