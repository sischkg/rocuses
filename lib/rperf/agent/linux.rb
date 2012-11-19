# -*- coding: utf-8 -*-

require 'pp'
require 'rperf/resource'

module RPerf
  class Agent
    class Linux
      # RETURN:: true: RedHat,CentOS Linux 6.x false, Debian wheezy/sidである場合
      def self.match_environment?
        begin
          File.open( '/etc/redhat-release' ) { |input|
            line = input.gets
            if line =~ /Red Hat Enterprise Linux Server release 6/
              return true
            elsif line =~ /CentOS release 6/
              return true
            elsif line =~ /Fedora release 17/
              return true
            end
          }
        rescue
        end

        begin 
          File.open( '/etc/debian_version' ) { |input|
            line = input.gets
            if line =~ %r{wheezy/sid}
              return true
            end
          }
        rescue
        end

        return false
      end

      # CPUの統計情報を取得する
      def get_cpu_status( resource )
        cpus = Array.new
        File.open( '/proc/stat' ) { |input|
          input.each { |line|
            line.chomp!
            if line =~ /\A
                          cpu(\d+)   # CPU ID
                          \s+
                          (\d+)        # user
                          \s+
                          (\d+)        # nice
                          \s+
                          (\d+)        # system
                          \s+
                          (\d+)        # io wait
                          \s
                        /xm
              cpus.push( RPerf::Resource::CPU.new( :time   => Time.now,
                                                   :name   => $1,
                                                   :user   => ( $2.to_i + $3.to_i ) * 0.1,
                                                   :system => $3.to_i * 0.1,
                                                   :wait   => $4.to_i * 0.1 ) )
            end
          }
        }
        resource.cpus = cpus
      end

      # メモリ・スワップの統計情報を取得する
      def get_virtual_memory_status( resource )
        IO.popen( '/usr/bin/free -b' ) { |input|
          total_memory = 0
          used_memory  = 0
          buffer_memory = 0
          cache_memory = 0
          total_swap   = 0
          used_swap    = 0

          input.each { |line|
            if line =~ /Mem:\s+
                     (\d+)      # total
                     \s+
                     (\d+)      # used
                     \s+
                     (\d+)      # free
                     \s+
                     (\d+)      # share
                     \s+ 
                     (\d+)      # buffer
                     \s+
                     (\d+)      # cache
                     \s*/xm
              total_memory  = $1.to_i
              used_memory   = $2.to_i + $4.to_i
              buffer_memory = $5.to_i
              cache_memory  = $6.to_i
            elsif line =~ /Swap:\s+
                           (\d+)   # total
                           \s+
                           (\d+)   # used
                           \s+/xm
              total_swap = $1.to_i
              used_swap  = $2.to_i
            end
          }

          resource.virtual_memory = RPerf::Resource::VirtualMemory.new( :time          => Time.now,
                                                                        :total_memory  => total_memory,
                                                                        :used_memory   => used_memory,
                                                                        :cache_memory  => cache_memory,
                                                                        :buffer_memory => buffer_memory,
                                                                        :total_swap    => total_swap,
                                                                        :used_swap     => used_swap )
        }
      end


      # ネットワークインターフェースの統計情報を取得する。
      def get_network_interface_status( resource )
        IO.popen( '/sbin/ifconfig -a' ) { |input|
          interface = Hash.new
          interface[:link_status] = :down
          interface[:time]        = Time.now

          input.each { |line|
            if line =~ /\A(\S+) /                # interface name
              interface[:name] = $1
            elsif line =~ /\A\s+UP\s/            # link_status
              interface[:link_status] = :up
            elsif line =~ /\A\s+RX packets:(\d+) errors:(\d+) dropped:(\d+) overruns:(\d+) frame:(\d+)/    # inbound packet and error count
              interface[:inbound_packet_count]  = $1.to_i
              interface[:inbound_error_count]   = $2.to_i + $3.to_i + $4.to_i + $5.to_i
            elsif line =~ /\A\s+TX packets:(\d+) errors:(\d+) dropped:(\d+) overruns:(\d+) carrier:(\d+)/ # outbound packet and error count
              interface[:outbound_packet_count] = $1.to_i
              interface[:outbound_error_count]  = $2.to_i + $3.to_i + $4.to_i + $5.to_i
            elsif line =~ /\A\s+RX bytes:(\d+) .* TX bytes:(\d+) /                                        # inbound and outbound data size
              interface[:inbound_data_size]  = $1.to_i
              interface[:outbound_data_size] = $2.to_i
            elsif line =~ /\A\s*\z/                                                                       # end of nic statistics infomation
              resource.network_interfaces.push( RPerf::Resource::NetworkInterface.new( interface ) )
              interface = Hash.new
              interface[:link_status] = :down
              interface[:time] = Time.now
            end
          }
        }
      end
      # wlan0     Link encap:Ethernet  HWaddr 40:25:c2:bc:2a:54                      # interface name
      #          inet addr:172.16.253.63  Bcast:172.16.253.255  Mask:255.255.255.0
      #          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1                  # link status
      #          RX packets:15590 errors:0 dropped:2 overruns:0 frame:0              # inbound packet and error count
      #          TX packets:12466 errors:0 dropped:0 overruns:0 carrier:0            # outbound packet and error count
      #          collisions:0 txqueuelen:1000 
      #          RX bytes:13214091 (13.2 MB)  TX bytes:2209794 (2.2 MB)              # inbound and outbound data size
      #                                                                              # enf of wlan statistics infomation
      #  eth0     Link encap:Ethernet  HWaddr 40:25:c2:bc:2a:aa


      # 全プロセスを取得する。
      def get_processes( resource )
        IO.popen( '/bin/ps -e --no-header -o pid,ppid,uid,gid,etime,args' ) { |input|
          input.each { |line|
            line.chomp!
            if line =~ /\A\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S.*)\z/
              argument   = $6
              pid        = $1.to_i
              parent_pid = $2.to_i
              uid        = $3.to_i
              gid        = $4.to_i

              elapsed_time_str = $5
              elapsed_time = 0
              if elapsed_time_str =~ /\A(\d+)-(\d+):(\d+):(\d+)\z/
                elapsed_time = RPerf::Utils::datetime_to_second( :day    => $1,
                                                                 :hour   => $2,
                                                                 :minute => $3,
                                                                 :second => $4 )
              elsif elapsed_time_str =~ /\A(\d+):(\d+):(\d+)\z/
                elapsed_time = RPerf::Utils::datetime_to_second( :hour   => $1,
                                                                 :minute => $2,
                                                                 :second => $3 )
              elsif elapsed_time_str =~ /(\d+):(\d+)\z/
                elapsed_time = RPerf::Utils::datetime_to_second( :minute => $1,
                                                                 :second => $2 )
              end
              now = Time.now
              start_time = now - elapsed_time
              resource.processes.push( RPerf::Resource::Process.new( :time       => now,
                                                                     :argument   => argument,
                                                                     :start_time => start_time,
                                                                     :pid        => pid,
                                                                     :parent_pid => parent_pid,
                                                                     :uid        => uid.to_i,
                                                                     :gid        => gid.to_i ) )
            end
          }
        }
      end

      # ファイルシステムの統計情報を取得する。
      def get_filesystem_status( resource )
        filesystem_of = Hash.new

        IO.popen( '/bin/df -k -l' ) { |input|
          input.gets
          input.each { |line|
            #            dev    total   used    available     mount point
            if line =~ /\A\S+\s+(\d+)\s+(\d+)\s+(\d+)\s+\S+\s+(\S+)\s*/
              filesystem_of[$4] = {
                :mount_point => $4,
                :total_size  => $1.to_i * 1024,
                :used_size   => $2.to_i * 1024,
                :free_size   => $3.to_i * 1024,
                :time        => Time.now,
              }
            end
          }
        }

        IO.popen( '/bin/df -i -l' ) { |input|
          input.gets
          input.each { |line|
            if line =~ /\A\S+\s+(\d+)\s+(\d+)\s+\d+\s+\S+\s+(\S+)\s*/
              mount_point = $3
              if filesystem_of.key?( mount_point )
                filesystem_of[mount_point][:total_files] = $1.to_i
                filesystem_of[mount_point][:used_files]  = $2.to_i
              end
            end
          }
        }

        filesystem_of.each { |mount_point, filesystem|
          if filesystem.key?( :total_files )
            resource.filesystems.push( RPerf::Resource::Filesystem.new( filesystem ) )
          end
        }
      end

      # Load Averageを取得する。
      def get_load_average( resource )
        IO.popen( '/usr/bin/uptime' ) { |input|
          line = input.gets
          if line =~ /load average: ([\d\.]+), ([\d\.]+), ([\d\.]+)\s*/
            resource.load_average = RPerf::Resource::LoadAverage.new( :time => Time.now,
                                                                      :la1  => $1.to_f,
                                                                      :la5  => $2.to_f,
                                                                      :la15 => $3.to_f )
          end
        }
      end
    end

  end
end

