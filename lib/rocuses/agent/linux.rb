# -*- coding: utf-8 -*-

require 'pp'
require 'log4r'
require 'rocuses/resource'
require 'rocuses/agentparameters'

module Rocuses
  class Agent
    class Linux
      include Rocuses
      include Log4r

      def initialize( agentconfig )
        @agentconfig = agentconfig
        @logger = Logger.new( 'rocuses::agent::linux' )
      end

      def name
        return "Rocuses::Agent::Linux"
      end

      GET_RESOURCE_METHOD_OF = {
        :CPU              => :get_cpus,
        :CPUAverage       => :get_cpu_average,
        :VirtualMemory    => :get_virtual_memory_status,
        :PageIO           => :get_page_io_status,
        :Filesystem       => :get_filesystems_status,
        :Processe         => :get_processes,
        :DiskIO           => :get_disk_ios,
        :LoadAverage      => :get_load_average,
        :NetworkInterface => :get_network_interfaces,
        :OpenLDAP         => :get_openldap,
        :OpenLDAPCache    => :get_openldap_caches,
      }

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
        if enable_resource?( type )
          send( GET_RESOURCE_METHOD_OF[ type.to_sym ], resource )
        end
      end

      # RETURN:: true: RedHat,CentOS Linux 6.x false, Debian wheezy/sidである場合
      def self.match_environment?( agentconfig )
        begin
          if File.readable?( '/etc/redhat-release' )
            File.open( '/etc/redhat-release' ) { |input|
              line = input.gets
              if line =~ /Red Hat Enterprise Linux Server release 6/
                return true
              elsif line =~ /CentOS release (5|6)/
                return true
              elsif line =~ /Fedora release 1(7|8)/
                return true
              end
            }
          end
        rescue => e
        end

        begin 
          if File.readable?( '/etc/debian_version' )
            File.open( '/etc/debian_version' ) { |input|
              line = input.gets
              if line =~ %r{wheezy/sid}
                return true
              elsif line =~ %r{7\.(0|1)}
                return true
              end
            }
          end
        rescue => e
        end

        return false
      end

      # 全CPUの統計情報の平均を取得する
      def get_cpu_average( resource )
        begin
          clock_tick = get_clock_tick()

          File.open( '/proc/stat' ) { |input|
            input.each { |line|
              line.chomp!
              if line =~ /\A
                          cpu          # CPU ID
                          \s+
                          (\d+)        # user
                          \s+
                          (\d+)        # nice
                          \s+
                          (\d+)        # system
                          \s+
                          \d+        # idle
                          \s+
                          (\d+)        # io wait
                          \s
                        /xm
                resource.cpu_average = Resource::CPU.new( :time   => Time.now,
                                                          :name   => 'AVERAGE',
                                                          :user   => $1.to_i / clock_tick,
                                                          :system => $3.to_i / clock_tick,
                                                          :wait   => $4.to_i / clock_tick )
              end
            }
          }
        rescue => e
          @logger.error( "cannot read /proc/stat( #{ e.to_s } )" )
        end
      end

      # CPUの統計情報を取得する
      def get_cpus( resource )
        begin 
          clock_tick = get_clock_tick()
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
                          \d+          # idle
                          \s+
                          (\d+)        # io wait
                          \s
                        /xm
                cpus.push( Resource::CPU.new( :time   => Time.now,
                                              :name   => $1,
                                              :user   => $2.to_i / clock_tick,
                                              :system => $4.to_i / clock_tick,
                                              :wait   => $5.to_i / clock_tick ) )
              end
            }
          }
          resource.cpus = cpus
        rescue => e
          @logger.error( "cannot read /proc/stat( #{ e.to_s } )" )
        end
      end

      # メモリ・スワップの統計情報を取得する
      def get_virtual_memory_status( resource )
        begin
          IO.popen( '/usr/bin/free -b' ) { |input|
            total_memory  = 0
            used_memory   = 0
            buffer_memory = 0
            cache_memory  = 0
            total_swap    = 0
            used_swap     = 0

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
                buffer_memory = $5.to_i
                cache_memory  = $6.to_i
                used_memory   = $2.to_i - cache_memory - buffer_memory
              elsif line =~ /Swap:\s+
                           (\d+)   # total
                           \s+
                           (\d+)   # used
                           \s+/xm
                total_swap = $1.to_i
                used_swap  = $2.to_i
              end
            }

            resource.virtual_memory = Resource::VirtualMemory.new( :time          => Time.now,
                                                                   :total_memory  => total_memory,
                                                                   :used_memory   => used_memory,
                                                                   :cache_memory  => cache_memory,
                                                                   :buffer_memory => buffer_memory,
                                                                   :total_swap    => total_swap,
                                                                   :used_swap     => used_swap )
          }
        rescue => e
          @logger.error( "cannot execute free -b( #{ e.to_s } )" )          
        end
      end

      # PageIOの統計情報を取得する
      def get_page_io_status( resource )
        begin
          File.open( '/proc/stat' ) { |input|
            input.each { |line|
              line.chomp!
              if line =~ /\A
                          page
                          \s+
                          (\d+)        # page in
                          \s+
                          (\d+)        # page out
                        /xm
                resource.page_io = Resource::PageIO.new( Time.now, $1.to_i, $2.to_i )
              end
            }
          }
        rescue => e
          @logger.error( "cannot read /proc/stat( #{ e.to_s } )" )
        end
      end

      # ネットワークインターフェースの統計情報を取得する。
      def get_network_interface_status( resource )
        begin
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
                if check_network_interface?( interface[:name] )
                  resource.network_interfaces.push( Resource::NetworkInterface.new( interface ) )
                end
                interface               = Hash.new
                interface[:link_status] = :down
                interface[:time]        = Time.now
              end
            }
          }
        rescue => e
          @logger.error( "cannot execute ifconfig( #{ e.to_s } )" )          
        end
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
        begin
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
                  elapsed_time = Utils::datetime_to_second( :day    => $1,
                                                            :hour   => $2,
                                                            :minute => $3,
                                                            :second => $4 )
                elsif elapsed_time_str =~ /\A(\d+):(\d+):(\d+)\z/
                  elapsed_time = Utils::datetime_to_second( :hour   => $1,
                                                            :minute => $2,
                                                            :second => $3 )
                elsif elapsed_time_str =~ /(\d+):(\d+)\z/
                  elapsed_time = Utils::datetime_to_second( :minute => $1,
                                                            :second => $2 )
                end
                now = Time.now
                start_time = now - elapsed_time
                resource.processes.push( Resource::Process.new( :time       => now,
                                                                :argument   => argument,
                                                                :start_time => start_time,
                                                                :pid        => pid,
                                                                :parent_pid => parent_pid,
                                                                :uid        => uid.to_i,
                                                                :gid        => gid.to_i ) )
              end
            }
          }
        rescue => e
          @logger.error( "cannot execute ps( #{ e.to_s } )" )          
        end
      end

      # ファイルシステムの統計情報を取得する。
      def get_filesystem_status( resource )
        filesystem_of = Hash.new

        begin
          IO.popen( '/bin/df -k -l' ) { |input|
            input.gets
            input.each { |line|
              #            dev    total   used    available     mount point
              if line =~ /\A\S+\s+(\d+)\s+(\d+)\s+(\d+)\s+\S+\s+(\S+)\s*/
                mount_point = $4
                if check_filesystem?( mount_point )
                  filesystem_of[mount_point] = {
                    :mount_point => mount_point,
                    :total_size  => $1.to_i * 1024,
                    :used_size   => $2.to_i * 1024,
                    :free_size   => $3.to_i * 1024,
                    :time        => Time.now,
                  }
                end
              end
            }
          }
          
          IO.popen( '/bin/df -i -l' ) { |input|
            input.gets
            input.each { |line|
              if line =~ /\A\S+\s+(\d+)\s+(\d+)\s+\d+\s+\S+\s+(\S+)\s*/
                mount_point = $3
                if check_filesystem?( mount_point )
                  if filesystem_of.key?( mount_point )
                    filesystem_of[mount_point][:total_files] = $1.to_i
                    filesystem_of[mount_point][:used_files]  = $2.to_i
                  end
                end
              end
            }
          }

          filesystem_of.each { |mount_point, filesystem|
            if filesystem.key?( :total_files )
              resource.filesystems.push( Resource::Filesystem.new( filesystem ) )
            end
          }
        rescue => e
          @logger.info( "cannot read filesystem statistics( #{ e.to_s } )" )
        end
      end

      # Load Averageを取得する。
      def get_load_average( resource )
        begin
          File.open( '/proc/loadavg' ) { |input|
            line = input.gets
            if line =~ %r{([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)/(\d+)\s+(\d+)\s*}
              resource.load_average = Resource::LoadAverage.new( :time => Time.now,
                                                                 :la1  => $1.to_f,
                                                                 :la5  => $2.to_f,
                                                                 :la15 => $3.to_f )
            end
          }
        rescue => e
          @logger.info( "cannot load average from /usr/bin/uptime( #{ e.to_s } )" )
        end
      end

      # DiskIOを取得する
      def get_disk_ios( resource )
        begin
          File.open( '/proc/diskstats' ) { |input|
            input.each { |line|
              columns = line.split( /\s+/ )
              name              = columns[3]
              sector_size       = get_sector_size( name )
              read_count        = columns[4].to_i
              read_data_size    = columns[6].to_i  * sector_size
              write_count       = columns[8].to_i
              write_data_size   = columns[10].to_i * sector_size
              wait_time         = columns[13].to_i * 1000 * 1000
              queue_length_time = columns[14].to_i * 1000 * 1000

              if check_disk_io_device?( name )              
                resource.disk_ios.push( Resource::DiskIO.new( :time            => Time.now,
                                                              :name            => name,
                                                              :read_count      => read_count,
                                                              :read_data_size  => read_data_size,
                                                              :write_count     => write_count,
                                                              :write_data_size => write_data_size ) )
                resource.linux_disk_ios.push( Resource::LinuxDiskIO.new( :time              => Time.now,
                                                                         :name              => name,
                                                                         :wait_time         => wait_time,
                                                                         :queue_length_time => queue_length_time ) )
              end
            }
          }
        rescue => e
          @logger.error( "cannot read /proc/diskstats( #{ e.to_s } )" )          
        end
      end

      # hostnameのOpenLDAP(slapd)へ接続し、Monitorデータベースの情報を取得する。
      # hostname:: 情報を取得するサーバのhostname
      # port:: LDAP接続するPORT
      # RETURN:: リソース情報 MJS::Perf::Resource::Data
      def fetch_openldap( hostname, port, bind_dn, bind_password )
        openldap_args =  Hash.new
        OPENLDAP_MONITOR_ENTRY_OF.each { |key, entry_info|
          begin
            Net::LDAP.open( :host => hostname,
                            :port => port,
                            :auth => {
                              :method   => :simple,
                              :username => bind_dn,
                              :password => bind_password
                            } ) { |ldap|
              openldap_args[:time] = Time.now
              openldap_args[key] = get_openldap_monitor_value( ldap, entry_info[:dn], entry_info[:attribute] )
            }            
          rescue => e
            raise FetchError.new( e.to_s )
          end
        }
        return MJS::Perf::Resource::Data.new( :openldap => MJS::Perf::Resource::OpenLDAP.new( openldap_args ) )
      end

      private

      # デバイスdeviceのSector Size(bytes)を取得する。
      # /sys/block/#{ device }/queue/physical_block_size もしくは /sys/block/#{ name }/queue/hw_sector_size 
      # からsector sizeを取得する。上記ファイルが存在しなかった場合は、deviceはパーティションの可能性があるため、
      # ディスク名へ変換( sda1, sdb2 => sda, sdb )して、再度試みる。
      # sector sizeを取得できなかった場合は、512を返す。
      def get_sector_size( device )
        [ device, device.gsub( %r{\d+}, %q{} ) ].each { |name|
          [ "physical_block_size", "hw_sector_size" ].each { |filename|
            begin
              path = "/sys/block/#{ name }/queue/#{filename}"
              if File.readable?( path )
                File.open( path ) { |input|
                  return input.gets.chomp!.to_i
                }
              end
            rescue => e
              @logger.debug( "cannot read secter size from #{ filename }( #{ e.to_s } )" )
            end
          }
        }
        @logger.info( "cannot read secter size, and use default value 512" )
        return 512
      end

      def get_clock_tick()
        if @clock_tick
          return @clock_tick
        end

        clock_tick = 100
        begin
          IO.popen( '/usr/bin/getconf CLK_TCK' ) { |input|
            line = input.gets
            clock_tick = line.chomp.to_i
          }
        rescue => e
          @logger.error( "cannot read CLK_TCK( #{ e.to_s } ), and use default tick" )
        end

        @clock_tick = clock_tick
        return @clock_tick
      end

      # ファイルシステムmount_pointは使用量取得対象あるかを判定する
      # mount_point:: ファイルシステムのmount_point
      # RETURN:: true: mount_pointは使用量取得対象である / false: mountは使用量取得対象ではない
      def check_filesystem?( mount_point )
        AgentParameters::SKIP_FILESYSTEMS_ON_LINUX.each { |pattern|
          if mount_point =~ pattern
            return false
          end
        }
        return true
      end

      # ネットワークインターフェースnameは情報取得対象あるかを判定する
      # name:: ネットワークインターフェース名
      # RETURN:: true: nameは取得対象である / false: nameは取得対象ではない
      def check_network_interface?( name )
        AgentParameters::SKIP_NETWORK_INTERFACES_ON_LINUX.each { |pattern|
          if name =~ pattern
            return false
          end
        }
        return true
      end

      # デバイスnameはDiskIO情報取得対象あるかを判定する
      # name:: ディスク名
      # RETURN:: true: nameは取得対象である / false: nameは取得対象ではない
      def check_disk_io_device?( name )
        AgentParameters::SKIP_DISK_IO_DEVICES_ON_LINUX.each { |pattern|
          if name =~ pattern
            return false
          end
        }
        return true
      end

    end
  end
end

