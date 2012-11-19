# -*- coding: utf-8 -*-

require 'yaml'
require 'rperf/resource/cpu'
require 'rperf/resource/virtualmemory'
require 'rperf/resource/filesystem'
require 'rperf/resource/process'
require 'rperf/resource/loadaverage'
require 'rperf/resource/networkinterface'
require 'rperf/resource/diskio'


module RPerf
  # リソースを表すクラス
  class Resource

    # 各CPUの統計情報
    attr_accessor :cpus

    # メモリ・スワップの統計情報
    attr_accessor :virtual_memory

    # 各ファイルシステムの統計情報
    attr_accessor :filesystems

    # 全プロセス
    attr_accessor :processes

    # Load Average
    attr_accessor :load_average

    # ネットワークインターフェースの統計情報
    attr_accessor :network_interfaces

    # 各ディスクのIO
    attr_accessor :disk_ios

    def initialize
      @cpus               = Array.new
      @filesystems        = Array.new
      @processes          = Array.new
      @network_interfaces = Array.new
      @disk_ios           = Array.new
    end

    def serialize
      YAML.dump( self )
    end

    def self.deserialize( stream )
      return YAML.load( stream )
    end
  end
end
