# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class BindInfo

      # rndcのPATH
      attr_reader :rndc_path

      # bindのバージョン
      attr_reader :version

      # ::rndc_path rndcのPATH
      # ::version bindのバージョン
      def initialize( rndc_path, version )
        @rndc_path = rndc_path
        @version   = version
      end

    end

    class Bind
      include Rocuses
      include Log4r

      def initialize( bind_info )
        @bind_info = bind_info
        @logger = Logger.new( 'rocuses::agent::bind' )
      end

      def name
        return "Rocuses::Agent::Bind"
      end

      GET_RESOURCE_METHOD_OF = {
        :Bind      => :get_bind_statistics,
      }

      RNDC_PATHS = [ '/usr/local/bind/sbin/rndc',
                     '/usr/local/sbin/rndc',
                     '/usr/sbin/rndc' ]

      STATISTICS_FILES = [ '/var/named/chroot/var/named/data/named_stats.txt',
                           '/var/named/data/named_stats.txt',
                           '/var/named/named.stats' ]

      STATS_FILE_LOCK = '/tmp/rocusagent.named_stats.lock'

      def enable_resource?( type )
        return GET_RESOURCE_METHOD_OF.key?( type.to_sym )
      end

      def list_enable_resources()
        return GET_RESOURCE_METHOD_OF.keys
      end

      # typeで指定したリソースの統計情報を取得し、resourceにその値を追加する
      # typeで指定したリソースを取得できない場合は、ArgumetErrorをraiseする。
      # type:: リソースのタイプ GET_RESOURCE_METHOD_OFのkeyのいずれか
      # resource:: 取得したリソースの統計情報の保存先
      def get_resource( type, resource )
        if ! enable_resource?( type )
          raise ArgumentError.new( "not support type #{type}" )
        end
        send( GET_RESOURCE_METHOD_OF[ type.to_sym ], resource )
      end

      def self.bind_version
        RNDC_PATHS.each { |rndc|
          if File.executable?( rndc )
            rndc_command = "#{ rndc } status 2> /dev/null"
            named_status = :down
            version = nil
            IO.popen( rndc_command ) { |input|
              while line = input.gets
                line.chomp!
                if line =~ /\Aversion:\s*(\S+)\s*\z/
                  version = $1
                elsif line =~ /server is up and running/
                  named_status = :up
                end
              end
            }
          end

          if named_status == :up
            return BindInfo.new( rndc, version )
          end
        }
        return nil
      end

      # RETURN:: true: Bind 9.8, 9.7, 9.6 
      def self.match_environment?
        bind_info = bind_version()
        if bind_info && bind_info.version =~ /\A9\.(6|7|8)/
          return bind_info
        end

        return nil
      end


      def get_bind_statistics( resource )
        statistics_file = load_statistics_file()
        if statistics_file.nil?
          return
        end

        get_name_server_statistics( resource, statistics_file )
        get_named_cache_statistics( resource, statistics_file )
      end

      private

      # Name Server Statisticsを取得する
      def get_name_server_statistics( resource, statistics_file )
        statistics = Hash.new
        name_server_statistics = false
        statistics_file.split( "\n" ).each { |line|
          if line =~/\A\+\+ Name Server Statistics \+\+\z/
            name_server_statistics = true
            next
          elsif line =~/\A\+\+ .* \+\+\z/ && name_server_statistics
            break
          elsif name_server_statistics
            if line =~ /\s+(\d+) (\w.*)\z/
              count = $1.to_i
              statistics_name = $2

              case statistics_name
              when 'IPv4 requests received'
                statistics[:request_ipv4] = count
              when 'requests with EDNS(0) received'
                statistics[:request_edns0] = count
              when 'TCP requests received'
                statistics[:request_tcp] = count
              when 'recursive queries rejected'
                statistics[:reject_recursive_requests_] = count
              when 'responses sent'
                statistics[:response] = count
              when 'responses with EDNS(0) sent'
                statistics[:response_edns0] = count
              when 'queries resulted in successful answer'
                statistics[:success] = count
              when 'queries resulted in authoritative answer'
                statistics[:authorative_answer] = count
              when 'queries resulted in non authoritative answer'
                statistics[:non_authorative_answer] = count
              when 'queries resulted in nxrrset'
                statistics[:nxrrset] = count
              when 'queries resulted in SERVFAIL'
                statistics[:servfail] = count
              when 'queries resulted in NXDOMAIN'
                statistics[:nxdomain] = count
              when 'queries caused recursion'
                statistics[:recursion] = count
              end
            end
          end
        }

        statistics[:time] = Time.now
        resource.bind = Resource::Bind.new( statistics )
      end


      def get_named_cache_statistics( resource, statistics_file )
        cache_statisticses = Array.new
        if statistics_file =~ %r{
            \+\+\sCache\sDB\sRRsets\s\+\+
            (.*)
            \+\+\sSocket\sI/O\sStatistics\s\+\+
          }xm
          cache_db_section = $1
          cache_db_section.scan( %r{\[View: .*\][^\[]+} ) { |view|
            cache_statisticses << parse_cache_db_statistics( view )
          }
        end

        resource.bindcaches = cache_statisticses
      end

      # rndc statsを実行し、statistics fileを読む
      # ::return statistics file
      def load_statistics_file
        File.open( STATS_FILE_LOCK, File::WRONLY|File::CREAT ) { |lock|
          lock.flock( File::LOCK_EX )
          rndc_stats = "#{ @bind_info.rndc_path } stats"
          system( rndc_stats )
          sleep( 1 )

          statistics = %q{}
          STATISTICS_FILES.each { |statistics_file|
            begin
              if File.readable?( statistics_file )
                File.open( statistics_file ) { |input|
                  statistics = input.gets( nil )
                }
                File.unlink( statistics_file )
                return statistics
              end
            rescue => e
              @logger.warn( "cannot load #{ statistics_file }( #{ e.to_s } )" )
            end
          }
          return nil
        }
      end

      def parse_cache_db_statistics( cache )
        cache_statistics = Hash.new
        view = %q{}
        cache.split( "\n" ).each { |line|
          if line =~ /\A\[View:\s(.+)\]/
            view = $1
          elsif line =~ /\s*(\d+) (\S+)\z/
            cache_statistics[$2] = $1.to_i
          end
        }

        return Resource::BindCache.new( :time  => Time.now,
                                        :view  => view,
                                        :cache => cache_statistics )
      end
    end
  end
end

