# -*- coding: utf-8 -*-

require 'rperf/utils'

module RPerf
  class Resource

    # CPUの処理時間を保持するクラス
    class CPU 

      # データ取得時刻
      attr_reader :time

      # CPU ID
      attr_reader :name

      # ユーザのCPU使用時間(second)
      attr_reader :user

      # カーネルのCPU使用時間(second)
      attr_reader :system

      # I/O Wait (second)
      attr_reader :wait

      # time:: データ取得時刻
      # name:: CPU ID
      # user:: ユーザのCPU使用時間(second)
      # system:: カーネルのCPU使用時間(second)
      # wait:: I/O Wait (second)
      def initialize( args )
        RPerf::Utils::check_args( args,
                                  {
                                    :time   => :req,
                                    :name   => :req,
                                    :user   => :req,
                                    :system => :req,
                                    :wait   => :req,
                                  } )
        @time   = args[:time]
        @name   = args[:name]
        @user   = args[:user]
        @system = args[:system]
        @wait   = args[:wait]
      end
    end
  end
end
