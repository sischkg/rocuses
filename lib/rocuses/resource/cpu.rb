# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  class Resource

    # CPUの処理時間を保持するクラス
    class CPU 
      include Rocuses
      include Comparable

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
        Utils::check_args( args,
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

      def <=>( other )
        time_compare   = ( @time   <=> other.time )
        name_compare   = ( @name   <=> other.name )
        user_compare   = ( @user   <=> other.user )
        system_compare = ( @system <=> other.system )
        wait_compare   = ( @wait   <=> other.wait )

        if time_compare != 0
          return time_compare
        elsif name_compare != 0
          return name_compare
        elsif user_compare != 0
          return user_compare
        elsif system_compare != 0
          return system_compare
        else
          return wait_compare
        end
      end
    end
  end
end
