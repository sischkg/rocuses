# -*- coding: utf-8 -*-

require 'yaml'
require 'rocuses/resource/cpu'
require 'rocuses/resource/virtualmemory'
require 'rocuses/resource/filesystem'
require 'rocuses/resource/process'
require 'rocuses/resource/loadaverage'
require 'rocuses/resource/networkinterface'
require 'rocuses/resource/diskio'
require 'rocuses/resource/linuxdiskio'

require 'rocuses/resource/bind'
require 'rocuses/resource/bindcache'


module Rocuses
  # リソースを表すクラス
  class Resource

    # 全CPUの統計情報の平均
    attr_accessor :cpu_average

    # 各CPUの統計情報
    attr_accessor :cpus

    # VMの統計情報
    attr_accessor :virtual_memory

    # 各ファイルシステムの統計情報
    attr_accessor :filesystems

    # Page In/Out
    attr_accessor :page_io

    # 全プロセス
    attr_accessor :processes

    # Load Average
    attr_accessor :load_average

    # ネットワークインターフェースの統計情報
    attr_accessor :network_interfaces

    # 各ディスクのIO
    attr_accessor :disk_ios

    # 各ディスクのIO(Linux)
    attr_accessor :linux_disk_ios

    # Bindの統計情報
    attr_accessor :bind

    # Bindキャッシュの統計情報
    attr_accessor :bindcaches

    def initialize
      @cpus               = Array.new
      @filesystems        = Array.new
      @processes          = Array.new
      @network_interfaces = Array.new
      @disk_ios           = Array.new
      @linux_disk_ios     = Array.new
      @bindcaches         = Array.new
    end

    def serialize
      YAML.dump( self )
    end

    def self.deserialize( stream )
      return YAML.load( stream )
    end
  end
end
