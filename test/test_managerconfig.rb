# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'args/test'
require 'rperf/config/managerconfig'

class LoadManagerConfigXMLTest < Test::Unit::TestCase

  must "check_default_values" do
    config = RPerf::Config::ManagerConfig.new
    assert_equal( 'rrdtool',        config.rrdtool_path )
    assert_equal( 300,              config.step )
    assert_equal( 600,              config.heartbeat )
    assert_equal( '/var/rperf/rra', config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end

  must "parse empty manager config xml file" do
    test_xml = "<rperf><manager><options></options></manager></rperf>"
    config = RPerf::Config::ManagerConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }

    assert_equal( 'rrdtool',        config.rrdtool_path )
    assert_equal( 300,              config.step )
    assert_equal( 600,              config.heartbeat )
    assert_equal( '/var/rperf/rra', config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end

  must "parse manager config xml file" do
    test_xml = <<'END_XML'
<rperf>
  <manager>
    <options>
      <rrdtool path="/usr/local/bin/rrdtool"/>
      <step time="60"/>
      <heartbeat step="300"/>
      <rra directory="/usr/local/rperf/rra"/>
    </options>
  </manager>
</rperf>
END_XML

    config = RPerf::Config::ManagerConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }

    assert_equal( '/usr/local/bin/rrdtool', config.rrdtool_path )
    assert_equal( 60,                       config.step )
    assert_equal( 300,                      config.heartbeat )
    assert_equal( '/usr/local/rperf/rra',   config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end
end
