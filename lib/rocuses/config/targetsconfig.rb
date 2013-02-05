# -*- coding: utf-8 -*-

require 'rexml/document'
require 'rocuses/utils'
require 'rocuses/config/default'

module Rocuses
  module Config

    # プロセス数の取得対象を表すクラス
    class Process

      # グラフ名
      attr_reader :name

      attr_reader :pattern

      def initialize( args )
        Utils::check_args( args, { :name => :req, :pattern => :req } )
        @name    = args[:name]
        @pattern = args[:pattern]
      end
    end

    # トラフィック取得対象を表すクラス
    class Traffic

      # トラフィック取得対象のネットワークインターフェースのArray
      attr_reader :interfaces

      # グラフ名
      attr_reader :name

      def initialize( args )
        Utils::check_args( args, { :name => :req, :interfaces => :req } )
        @name       = args[:name]
        @interfaces = args[:interfaces]
      end
    end

    # リソース情報取得対象を表すクラス
    class Target

      # 名前
      attr_reader :name

      # 取得対称nodeへ接続するためのhostname/IP address
      attr_reader :hostname

      # 取得対称nodeへ接続するためのport
      attr_reader :port

      # 取得対象プロセス
      attr_reader :processes

      # 取得対象ファイルシステム
      attr_reader :filesystems

      # 取得対象トラフィック
      attr_reader :traffics

      # DiskIO取得対象デバイスファイル
      attr_reader :disk_ios

      def initialize( args )
        Utils::check_args( args, {
                            :name        => :req,
                            :hostname    => :req,
                            :port        => :req,
                            :processes   => :op,
                            :filesystems => :op,
                            :traffics    => :op,
                            :disk_ios    => :op,
                          } )

        @name        = args[:name]
        @hostname    = args[:hostname]
        @port        = args[:port]
        @processes   = args[:processes]
        @filesystems = args[:filesystems]
        @traffics    = args[:traffics]
        @disk_ios    = args[:disk_ios]
      end

    end
    
    # Target設定管理
    # リソース取得対象の設定を管理する
    #
    #  config = Rocuses::Config::TargetsConfig.new
    #  config.load( File.new( "taregetsconfig.xml" ) )
    #
    #
    # 設定XMLサンプル
    # <rocuses>
    #   <targets>
    #     <target node="node01" hostname="192.168.0.1">
    #     </target>
    #     <target node="node02" hostname="192.168.0.2" port="10080">
    #     </target>
    #     <target node="node03" hostname="192.168.0.3">
    #       <process name="sendmail" pattern="/usr/lib/sendmail -bd"/>
    #       <process name="httpd"    pattern="/usr/local/apache2/bin/httpd"/>
    #       <disk_io  device="/dev/hda"/>
    #       <filesystem mount_point="/home"/>
    #       <traffic name="global"">
    #         <interface name="eth0"/>
    #         <interface name="eth1"/>
    #       </traffic>
    #     </target>
    #   </targets>
    # </rocuses>
    #
    class TargetsConfig

      # リース情報取得対象TargetのArray
      attr_reader :targets

      def initialize
        @targets = Array.new
      end

      # 設定XMLファイルをロードする
      # input:: 設定XMLファイルのFileオブジェクトなどのIOオブジェクト
      def load( input )
        doc = REXML::Document.new( input )
        load_targets( doc )
      end

      private

      # <rocuses><targets><target name="> .... </target></targets></rocuses>
      # を取得する。
      # doc:: REXML::Document
      # name:: Elementの名前
      def load_targets( doc )
        doc.elements.each( 'rocuses/targets/target' ) { |element|
          name     = element.attributes['name']
          hostname = element.attributes['hostname']
          port     = element.attributes['port']

          if name.nil? || hostname.nil?
            raise ArgumentError.new( %q{please set name,hostname( <target name="..." hostname="..." ></targets> )} )
          end
          if port.nil?
            port = Rocuses::Config::Default::BIND_PORT
          end

          @targets.push( Target.new( :name        => name,
                                     :hostname    => hostname,
                                     :port        => port.to_i,
                                     :processes   => load_processes( element ),
                                     :filesystems => load_filesystems( element ),
                                     :disk_ios    => load_disk_ios( element ),
                                     :traffics    => load_traffics( element ) ) )
        }
      end

      def load_filesystems( target )
        filesystems = Array.new
        target.elements.each( 'filesystem' ) { |child|
          mount_point = child.attributes['mount_point']
          
          if mount_point.nil?
            raise ArgumentError.new( %q{please set mount_point( <filesystem mount_point="...." )/> )} )
          end

          filesystems.push( mount_point )
        }
        return filesystems
      end

      def load_processes( target )
        processes = Array.new
        target.elements.each( 'process' ) { |child|
          name    = child.attributes['name']
          pattern = child.attributes['pattern']
          
          if name.nil? || pattern.nil?
            raise ArgumentError.new( %q{please set name,pattern( <process name="..." pattern="...." )/> )} )
          end

          processes.push( Process.new( :name => name, :pattern => Regexp.new( pattern ) ) )
        }
        return processes
      end

      def load_disk_ios( target )
        disk_ios = Array.new
        target.elements.each( 'disk_io' ) { |child|
          device = child.attributes['device']
          
          if device.nil?
            raise ArgumentError.new( %q{please set device( <disk_io device="...." )/> )} )
          end

          disk_ios.push( device )
        }
        return disk_ios
      end

      def load_traffics( target )
        traffics = Array.new
        target.elements.each( 'traffic' ) { |child|
          name = child.attributes["name"]
          
          if name.nil?
            raise ArgumentError.new( %q{please set name( <traffic name="..." )> )} )
          end

          interfaces = Array.new
          child.elements.each( 'interface' ) { |nic|
            interface_name = nic.attributes['name']
            if interface_name.nil?
              raise ArgumentError.new( %q{<interface/> must has name attribute(<interface name~"..."/>)} )
            end
            interfaces.push( interface_name )
          }
          if interfaces.size == 0
            raise ArgumentError.new( %q{<traffic> must has <interface/> elements(<traffic name="..."><iterface nane="..."></traffic>} )
          end

          traffics.push( Traffic.new( :name => name, :interfaces => interfaces ) )
        }
        return traffics
      end
    end
  end
end
