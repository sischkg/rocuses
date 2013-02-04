# -*- coding: utf-8 -*-

require 'rocuses/utils'
require 'pp'

module Rocuses
  module RRDTool
    class DataSource
      include Rocuses

      AVAILABLE_DATASOURCE_TYPES = [ :GAUGE, :COUNTER, :ABSOLUTE, :DERIVE ]

      # Data Source Name
      attr_reader :name

      # Data Source Type :GAUGE or :COUNTER or :ABSOLUTE or :DERIVE
      attr_reader :type

      # 最小値
      attr_reader :lower_limit

      # 最大値
      attr_reader :upper_limit

      # 予測を行うか true/false
      attr_reader :predict

      # name:: データの名前
      # type:: DST :COUNTER or :GUAGE or :ABSOLUTE or :DERIVE
      # lower_limit:: データの最小値
      # upper_limit:: データの最大値
      # predict:: 予測をするか true/false
      # predict_alpha:: 0-1.0
      # predict_beta:: 0-1.0
      # predict_gamma:: 0-1.0
      # predict_seasonal_period:: 周期( second )
      def initialize( args )
        args = Args::check_args( args,
                                 {
                                   :name        => :req,
                                   :type        => :req,
                                   :step        => :req,
                                   :heartbeat   => :req,
                                   :lower_limit => :op,
                                   :upper_limit => :op,
                                   :predict                 => :op,
                                   :predict_alpha           => :op,
                                   :predict_beta            => :op,
                                   :predict_gamma           => :op,
                                   :predict_seasonal_period => :op,
                                   :predict_threshold       => :op,
                                   :predict_window_length   => :op,
                                 },
                                 {
                                   :lower_limit => 'U',
                                   :upper_limit => 'U',
                                   :predict     => false,
                                 } )
        
        if args[:predict]
          Utils::check_args( args,
                            {
                              :name        => :req,
                              :type        => :req,
                              :step        => :req,
                              :heartbeat   => :req,
                              :lower_limit => :op,
                              :upper_limit => :op,
                              :predict                 => :req,
                              :predict_alpha           => :req,
                              :predict_beta            => :req,
                              :predict_gamma           => :op,
                              :predict_seasonal_period => :req,
                              :predict_threshold       => :op,
                              :predict_window_length   => :op,
                            } )
        end

        @name        = args[:name]
        @type        = args[:type]
        @step        = args[:step]
        @heartbeat    = args[:heartbeat]
        @lower_limit = args[:lower_limit]
        @upper_limit = args[:upper_limit]
        @predict     = args[:predict]
        if @predict
          @predict_alpha           = args[:predict_alpha].to_f
          @predict_beta            = args[:predict_beta].to_f
          @predict_seasonal_period = args[:predict_seasonal_period].to_i
          @predict_gamma           = 0.3
          @predict_threshold       = 7
          @predict_window_length   = 9
          if args.key?( :predict_gamma )
            @predict_gamma = args[:predict_gamma].to_f
          end
          if args.key?( :predict_threshold )
            @predict_threshold = args[:predict_threshold].to_i
          end
          if args.key?( :predict_window_length )
            @predict_window_length = args[:predict_window_length].to_i
          end
        end

        if ! AVAILABLE_DATASOURCE_TYPES.include?( @type )
          raise %Q["#{ @name }" is invalid data source type of #{ @name }]
        end
      end

      # RRDを作成する
      def create()
        if File.exist?( filename() )
          return
        end
        
        cmd =
          %Q[#{ filename() } ] +
          %Q[ --step #{ @step } ] +
          %Q[ DS:value:#{ @type }:#{ @heartbeat }:#{ @lower_limit }:#{ @upper_limit } ]

        rows = 10 * 24 * 60 * 60 / @step

        [ 'AVERAGE', 'MAX', 'MIN', 'LAST' ].each { |cf|
          [ 1, 7, 31, 3*365 ].each { |step|
            cmd += %Q[ RRA:#{ cf }:0.5:#{ step }:#{ rows } ]
          }
        }

        if @predict
          period = @predict_seasonal_period / @step
          cmd += %Q[ RRA:HWPREDICT:#{ rows }:#{ @predict_alpha }:#{ @predict_beta }:#{ period }:18 ]
          cmd += %Q[ RRA:SEASONAL:#{ period }:#{ @predict_gamma }:17 ]
          cmd += %Q[ RRA:DEVSEASONAL:#{ period }:#{ @predict_gamma }:17 ]
          cmd += %Q[ RRA:DEVPREDICT:#{ rows }:19 ]
          cmd += %Q[ RRA:FAILURES:#{ rows }:#{ @predict_threshold }:#{ @predict_window_length }:19 ]
        end

        RRDTool.create( cmd )
      end
      # RRA                                 rra-num (for HWPREDICT)
      # RRA:AVERAGE:0.5:1:{ rows }          1
      # RRA:AVERAGE:0.5:7:{ rows }          2
      # RRA:AVERAGE:0.5:31:{ rows }         3
      # RRA:AVERAGE:0.5:365:{ rows }        4
      # RRA:MAX:0.5:1:{ rows }              5
      # RRA:MAX:0.5:7:{ rows }              6
      # RRA:MAX:0.5:31:{ rows }             7
      # RRA:MAX:0.5:365:{ rows }            8
      # RRA:MIN:0.5:1:{ rows }              9
      # RRA:MIN:0.5:7:{ rows }             10
      # RRA:MIN:0.5:31:{ rows }            11
      # RRA:MIN:0.5:365:{ rows }           12
      # RRA:LAST:0.5:1:{ rows }            13
      # RRA:LAST:0.5:7:{ rows }            14
      # RRA:LAST:0.5:31:{ rows }           15
      # RRA:LAST:0.5:365:{ rows }          16
      # RRA:HWPREDICT:{ rows }:{ alpha }:{ beta }:{ period }:{ seasonal rra-num = 18 }   17
      # RRA:SEASONAL:{ period }:{ gamma }:{ hwpredict rra-num = 17 }                     18
      # RRA:DEVSEASONAL:{ period }:{ gamma }:{ hwpredict rra-num = 17 }                  19
      # RRA:DEVPREDICT:{ rows }:{ devseasonal rra-num = 19 }                             20
      # RRA:FAILURES:{ rows ]:{ threshold }:{window_length}:{ devseasonal rra_num = 19 } 21

      # RRDへデータを追加する
      # time:: データ取得時刻のTimeオブジェクト
      # value:: データ(Float）
      def update( time, value )
        create()
        cmd =
          %Q[ #{ filename() } ] +
          %Q[ #{ time.to_i }:#{ value.to_s } ]

        RRDTool.update( cmd )
      end

      def filename()
        RRDTool.rrd_filename( self )
      end
      
    end
  end
end
