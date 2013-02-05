# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'rocuses/test'
require 'rocuses/config/targetsconfig'

class LoadTargetsXMLTest < Test::Unit::TestCase

  def detect_error_test( xml )
    config = Rocuses::Config::TargetsConfig.new
    assert_raise( ArgumentError ) {
      config.load( xml )
    }
  end

  must "parse empty xml file" do
    test_xml = "<rocuses><targets></targets></rocuses>"
    config = Rocuses::Config::TargetsConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    assert_equal( 0, config.targets.size,  "no targets" )
  end

  must "parse xml file" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
    </target>
    <target name="node02" hostname="192.168.0.2" port="10080">
    </target>
    <target name="node03" hostname="192.168.0.3">
      <process name="sendmail" pattern="/usr/lib/sendmail -bd"/>
      <process name="httpd"    pattern="/usr/local/apache2/bin/httpd"/>
      <disk_io  device="/dev/hda"/>
      <disk_io  device="/dev/sda"/>
      <filesystem mount_point="/home"/>
      <filesystem mount_point="/"/>
      <traffic name="global">
        <interface name="eth0"/>
        <interface name="eth1"/>
      </traffic>
      <traffic name="private">
        <interface name="eth2"/>
        <interface name="eth3"/>
      </traffic>
    </target>
  </targets>
</rocuses>
END_XML

    config = Rocuses::Config::TargetsConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    targets = config.targets
    assert_equal( 3, targets.size, "load 3 targets" )

    assert_equal( 'node01',      targets[0].name,     'node01 name' )
    assert_equal( '192.168.0.1', targets[0].hostname, 'node01 hostname' )
    assert_equal( 20080,         targets[0].port,     'node01 port' )

    assert_equal( 'node02',      targets[1].name,     'node02 name' )
    assert_equal( '192.168.0.2', targets[1].hostname, 'node02 hostname' )
    assert_equal( 10080,         targets[1].port,     'node02 port' )

    assert_equal( 'node03',      targets[2].name,     'node02 name' )
    assert_equal( '192.168.0.3', targets[2].hostname, 'node02 hostname' )
    assert_equal( 20080,         targets[2].port,     'node03 port' )

    assert_equal( 'sendmail',                targets[2].processes[0].name,    'process name of sendamil' )
    assert_equal( %r{/usr/lib/sendmail -bd}, targets[2].processes[0].pattern, 'process regexp of sendmail' )
    assert_equal( 'httpd',                          targets[2].processes[1].name,    'process name of httpd' )
    assert_equal( %r{/usr/local/apache2/bin/httpd}, targets[2].processes[1].pattern, 'process regexp of httpd' )

    assert_equal( '/dev/hda',                targets[2].disk_ios[0], 'disk io device hda' )
    assert_equal( '/dev/sda',                targets[2].disk_ios[1], 'disk io device sda' )

    assert_equal( '/home', targets[2].filesystems[0], 'filesystem /home' )
    assert_equal( '/',     targets[2].filesystems[1], 'filesuytem /' )

    global_traffic = targets[2].traffics[0]
    assert( ! global_traffic.nil?, 'traffic global exists' )
    assert_equal( 'global',  global_traffic.name,            'global name' )
    assert_equal( 2,         global_traffic.interfaces.size, 'number global interfaces is 2' )
    assert_equal( 'eth0' ,   global_traffic.interfaces[0],   'global interface eth0' )
    assert_equal( 'eth1' ,   global_traffic.interfaces[1],   'global interface eth1' )

    private_traffic = targets[2].traffics[1]
    assert( ! private_traffic.nil?, 'traffic private exists' )
    assert_equal( 'private', private_traffic.name,            'private name' )
    assert_equal( 2,         private_traffic.interfaces.size, 'number private interfaces is 2' )
    assert_equal( 'eth2' ,   private_traffic.interfaces[0],   'private interface eth2' )
    assert_equal( 'eth3' ,   private_traffic.interfaces[1],   'private interface eth3' )
  end


  must "detect error of target element(no name)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target hostname="192.168.0.1">
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of target element(no hostname)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01">
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of filesystem element(no mount point)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <filesystem />
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of process element(no name)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <process pattern="/usr/lib/sendmail -bd" />
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of process element(no pattern)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <process name="sendmail" />
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of disk_io element(no device)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <disk_io />
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of traffic element(no name)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <traffic>
        <interface name="eth0"/>
      </traffic>
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of traffic element(no interface)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <traffic name="global">
      </traffic>
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end

  must "detect error of interface element(no name)" do
    test_xml = <<'END_XML'
<rocuses>
  <targets>
    <target name="node01" hostname="192.168.0.1">
      <traffic name="global">
        <interface/>
      </traffic>
    </target>
  </targets>
</rocuses>
END_XML

    detect_error_test( test_xml )
  end


end

