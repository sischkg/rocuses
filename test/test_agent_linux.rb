# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'pp'
require 'rocuses/test'
require 'rocuses/resource'
require 'rocuses/agent/linux'

class AgentLinuxTest < Test::Unit::TestCase
  CHECKED_TIME = Time.local( 2012, 11, 12, 00, 12, 34 )

  must "matched Red Hat Enterprise Linux Server release 6" do
    generate_readable_mock( '/etc/redhat-release' => true )
    generate_read_mock( '/etc/redhat-release' =>
                        [ 'Red Hat Enterprise Linux Server release 6' ] )
    assert( Rocuses::Agent::Linux.match_environment?, "matched RedHat Enterprise Linux Server 6" )
  end

  must "unmatched Red Hat Enterprise Linux Server release 5" do
    generate_readable_mock( '/etc/redhat-release' => true )
    generate_read_mock( '/etc/redhat-release' =>
                        [ 'Red Hat Enterprise Linux Server release 5' ] )
    assert( ! Rocuses::Agent::Linux.match_environment?, "unmatched RedHat Enterprise Linux Server 5" )
  end

  must "return load average" do
    generate_time_mock( CHECKED_TIME )
    generate_readable_mock( '/proc/loadavg' => true )
    generate_read_mock( '/proc/loadavg' =>
                        [ '1.11 2.22 3.33 2/300 10001' ] )
    assert( ! Rocuses::Agent::Linux.match_environment?, "unmatched RedHat Enterprise Linux Server 5" )

    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_load_average( resource )
    assert_in_delta( 1.11, resource.load_average.la1,  0.1, "get 1 minute load average" ) 
    assert_in_delta( 2.22, resource.load_average.la5,  0.1, "get 5 minute load average" ) 
    assert_in_delta( 3.33, resource.load_average.la15, 0.1, "get 15 minute load average" ) 
    assert_equal( CHECKED_TIME, resource.load_average.time, "get checked time" ) 
  end

  must "return virtual memory usage" do
    generate_popen_mock( '/usr/bin/free -b' =>
                         [
                          "             total       used       free     shared    buffers     cached\n",
                          "Mem:       1020580     947604      72976          0     150100     351424\n",
                          "-/+ buffers/cache:     446080     574500\n",
                          "Swap:      2097144          0    2097144\n"
                         ] )
    generate_time_mock( CHECKED_TIME )
    
    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_virtual_memory_status( resource )

    assert_equal( 1020580, resource.virtual_memory.total_memory,  "get total memory" )
    assert_equal(  947604 - 150100 - 351424,
                   resource.virtual_memory.used_memory,
                   "get used memory" )
    assert_equal(  150100, resource.virtual_memory.buffer_memory, "get buffer memory" )
    assert_equal( 2097144, resource.virtual_memory.total_swap,    "get total swap" )
    assert_equal(       0, resource.virtual_memory.used_swap,     "get used swap" )
    assert_equal( CHECKED_TIME, resource.virtual_memory.time, "get checked time" ) 
  end


  def assert_filesystem( filesystem_of, expected_of )
    expected_mount_point = expected_of[:mount_point]
    fs = filesystem_of[ expected_mount_point ]

    assert( filesystem_of.key?( expected_mount_point ),
            %Q{filesystem "#{ expected_mount_point }" exists.} )
    assert_equal( expected_of[:total_size],
                  fs.total_size,
                  %Q{get total size of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:used_size],
                  fs.used_size,
                  %Q{get used size of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:free_size],
                  fs.free_size,
                  %Q{get free size of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:total_files],
                  fs.total_files,
                  %Q{get total files of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:used_files],
                  fs.used_files,
                  %Q{get used files of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:total_files] - expected_of[:used_files],
                  fs.free_files,
                  %Q{get free files of "#{ expected_mount_point }" } )
    assert_equal( expected_of[:time],
                  fs.time,
                  %Q{get checked time of "#{ expected_mount_point }" } )
  end

  must "return filesystem usage" do

    df_k_results = [
                    "    Filesystem           1K-blocks      Used Available Use% Mounted on\n",
                    "/dev/vda3            100893076  80690020  15077888  85% /\n",
                    "tmpfs                   510288         0    510288   0% /dev/shm\n",
                    "/dev/vda1               247919     94603    140516  41% /boot\n",
                   ]

    df_i_results = [
                    "Filesystem            Inodes   IUsed   IFree IUse% Mounted on\n",
                    "/dev/vda3            6414336  116630 6297706    2% /\n",
                    "tmpfs                 127572       1  127571    1% /dev/shm\n",
                    "/dev/vda1              64000      56   63944    1% /boot\n",
                   ]

    generate_time_mock( CHECKED_TIME )
    generate_popen_mock( "/bin/df -k -l" => df_k_results,
                         "/bin/df -i -l" => df_i_results )

    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_filesystem_status( resource )

    filesystem_of = Hash.new
    resource.filesystems.each { |fs|
      filesystem_of[fs.mount_point] = fs
    }

    assert_filesystem( filesystem_of,
                       {
                         :time        => CHECKED_TIME,
                         :mount_point => '/',
                         :total_size  => 100893076 * 1024,
                         :used_size   => 80690020  * 1024,
                         :free_size   => 15077888  * 1024,
                         :total_files => 6414336,
                         :used_files  => 116630,
                       } )

    assert_filesystem( filesystem_of,
                       {
                         :time        => CHECKED_TIME,
                         :mount_point => '/dev/shm',
                         :total_size  => 510288 * 1024,
                         :used_size   => 0      * 1024,
                         :free_size   => 510288 * 1024,
                         :total_files => 127572,
                         :used_files  => 1,
                       } )
    assert_filesystem( filesystem_of,
                       {
                         :time        => CHECKED_TIME,
                         :mount_point => '/boot',
                         :total_size  => 247919 * 1024,
                         :used_size   => 94603  * 1024,
                         :free_size   => 140516 * 1024,
                         :total_files => 64000,
                         :used_files  => 56,
                       } )
  end


  def assert_process( process_of, expected_of )
    expected_process_argument = expected_of[:argument]
    process = process_of[ expected_process_argument ]

    elapsed_time = Rocuses::Utils::datetime_to_second( :day    => expected_of[:start_time_day],
                                                       :hour   => expected_of[:start_time_hour],
                                                       :minute => expected_of[:start_time_minute],
                                                       :second => expected_of[:start_time_second] )

    expected_start_time = CHECKED_TIME - elapsed_time

    assert( process_of.key?( expected_process_argument ),
            %Q{process "#{ expected_process_argument }" exists.} )
    assert_equal( expected_of[:pid],
                  process.pid,
                  %Q{get pid of "#{ expected_process_argument }" } )
    assert_equal( expected_of[:parent_pid],
                  process.parent_pid,
                  %Q{get parent pid of "#{ expected_process_argument }" } )
    assert_equal( expected_of[:uid],
                  process.uid,
                  %Q{get uid of "#{ expected_process_argument }" } )
    assert_equal( expected_of[:gid],
                  process.gid,
                  %Q{get gid of "#{ expected_process_argument }" } )
    assert_equal( expected_start_time,
                  process.start_time,
                  %Q{get start_time of "#{ expected_process_argument }" } )
    assert_equal( expected_of[:time],
                  process.time,
                  %Q{get checked time of "#{ expected_process_argument }" } )
  end

  must "return processes" do
    generate_popen_mock( '/bin/ps -e --no-header -o pid,ppid,uid,gid,etime,args' =>
                         [
                          " 1221  1206    89    90  5-04:19:30 qmgr -l -t fifo -u\n",
                          " 11056 11054     0     0    04:47:14 -bash\n",
                          " 11057 11056     0     0       10:20 grep ps\n",
                          " 11058 11056     0     0       00:30 sed\n",
                          " 11252 11056     0     0       00:00 ps -ef\n",
                         ] )
    generate_time_mock( CHECKED_TIME )

    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_processes( resource )
    process_of = Hash.new
    resource.processes.each { |process|
      process_of[process.argument] = process
    }

    assert_process( process_of,
                    {
                      :argument   => "qmgr -l -t fifo -u",
                      :time       => CHECKED_TIME,
                      :pid        => 1221,
                      :parent_pid => 1206,
                      :uid        => 89,
                      :gid        => 90,
                      :start_time_day    => 5,
                      :start_time_hour   => 4,
                      :start_time_minute => 19,
                      :start_time_second => 30,
                    } )

    assert_process( process_of,
                    {
                      :argument   => "-bash",
                      :time       => CHECKED_TIME,
                      :pid        => 11056,
                      :parent_pid => 11054,
                      :uid        => 0,
                      :gid        => 0,
                      :start_time_day    => 0,
                      :start_time_hour   => 4,
                      :start_time_minute => 47,
                      :start_time_second => 14,
                    } )

    assert_process( process_of,
                    {
                      :argument   => "grep ps",
                      :time       => CHECKED_TIME,
                      :pid        => 11057,
                      :parent_pid => 11056,
                      :uid        => 0,
                      :gid        => 0,
                      :start_time_day    => 0,
                      :start_time_hour   => 0,
                      :start_time_minute => 10,
                      :start_time_second => 20,
                    } )

    assert_process( process_of,
                    {
                      :argument   => "sed",
                      :time       => CHECKED_TIME,
                      :pid        => 11058,
                      :parent_pid => 11056,
                      :uid        => 0,
                      :gid        => 0,
                      :start_time_day    => 0,
                      :start_time_hour   => 0,
                      :start_time_minute => 0,
                      :start_time_second => 30,
                    } )

    assert_process( process_of,
                    {
                      :argument   => "ps -ef",
                      :time       => CHECKED_TIME,
                      :pid        => 11252,
                      :parent_pid => 11056,
                      :uid        => 0,
                      :gid        => 0,
                      :start_time_day    => 0,
                      :start_time_hour   => 0,
                      :start_time_minute => 0,
                      :start_time_second => 0,
                    } )
  end


  must "read diskstats" do
    generate_read_mock( '/proc/diskstats' => [ "  8       0 sda  31292 23536 1969110 143680 60310 55329 3358544 233720 0 64644 377440\n",
                                               "  8       0 sda1 31200 23500 1969000 143680 60300 55329 3358500 233720 0 64600 377400\n", ],
                        '/sys/block/sda/queue/physical_block_size' => [ "512\n" ] )
    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_disk_ios( resource )
    assert_equal( "sda",         resource.disk_ios[0].name,             "device" )
    assert_equal( 31292,         resource.disk_ios[0].read_count,       "read count" )
    assert_equal( 1969110 * 512, resource.disk_ios[0].read_data_size,   "read size" )
    assert_equal( 60310,         resource.disk_ios[0].write_count,      "write count" )
    assert_equal( 3358544 * 512, resource.disk_ios[0].write_data_size,  "write size" )
    assert_equal(  64644 * 1000 * 1000, resource.linux_disk_ios[0].wait_time,         "wait time" )
    assert_equal( 377440 * 1000 * 1000, resource.linux_disk_ios[0].queue_length_time, "queue length time" )

    assert_equal( "sda1",        resource.disk_ios[1].name,             "device" )
    assert_equal( 31200,         resource.disk_ios[1].read_count,       "read count" )
    assert_equal( 1969000 * 512, resource.disk_ios[1].read_data_size,   "read size" )
    assert_equal( 60300,         resource.disk_ios[1].write_count,      "write count" )
    assert_equal( 3358500 * 512, resource.disk_ios[1].write_data_size,  "write size" )
    assert_equal(  64600 * 1000 * 1000, resource.linux_disk_ios[1].wait_time,         "wait time" )
    assert_equal( 377400 * 1000 * 1000, resource.linux_disk_ios[1].queue_length_time, "queue length time" )
  end


  must "read stat for cpu" do
    CLK_TCK = 100

    generate_read_mock( '/proc/stat' => [ "cpu  1000 3 3000 400 600 \n",
                                          "cpu0 700 0 2000 300 400 \n",
                                          "cpu1 300 3 1000 100 200 \n" ] )
    generate_popen_mock( '/usr/bin/getconf CLK_TCK' => [ "#{ CLK_TCK }\n" ] )
    generate_time_mock( Time.at( 100 ) )
    
    resource = Rocuses::Resource.new
    expected_cpu_average = Rocuses::Resource::CPU.new( :time   => Time.at( 100 ),
                                                       :name   => 'AVERAGE',
                                                       :user   => 1000 / CLK_TCK,
                                                       :system => 3000 / CLK_TCK,
                                                       :wait   =>  600 / CLK_TCK )
    expected_cpu0 = Rocuses::Resource::CPU.new( :time   => Time.at( 100 ),
                                                :name   => '0',
                                                :user   =>  700 / CLK_TCK,
                                                :system => 2000 / CLK_TCK,
                                                :wait   =>  400 / CLK_TCK )
    expected_cpu1 = Rocuses::Resource::CPU.new( :time   => Time.at( 100 ),
                                                :name   => '1',
                                                :user   =>  300 / CLK_TCK,
                                                :system => 1000 / CLK_TCK,
                                                :wait   =>  200 / CLK_TCK )

    Rocuses::Agent::Linux.new.get_cpu_average( resource )
    assert_equal( expected_cpu_average, resource.cpu_average,  'CPU Average' )

    Rocuses::Agent::Linux.new.get_cpus( resource )
    assert_equal( expected_cpu0, resource.cpus[0],   'CPU 0' )
    assert_equal( expected_cpu1, resource.cpus[1],   'CPU 1' )
    assert_equal( 2,             resource.cpus.size, 'count of CPU' )
  end

  must "read stat for page io" do
    generate_read_mock( '/proc/stat' => [ "page 10 20\n", ] )
    generate_time_mock( Time.at( 100 ) )
    
    resource = Rocuses::Resource.new
    Rocuses::Agent::Linux.new.get_page_io_status( resource )
    assert_equal( 10, resource.page_io.page_in,  'page in' )
    assert_equal( 20, resource.page_io.page_out, 'page out' )
  end


end

