# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'args/test'
require 'rocuses/config/managerconfig'

class LoadManagerConfigXMLTest < Test::Unit::TestCase

  must "check_default_values" do
    config = Rocuses::Config::ManagerConfig.new
    assert_equal( 'rrdtool',        config.rrdtool_path )
    assert_equal( 300,              config.step )
    assert_equal( 600,              config.heartbeat )
    assert_equal( '/var/rocuses/rra', config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end

  must "parse empty manager config xml file" do
    test_xml = "<rocuses><manager><options></options></manager></rocuses>"
    config = Rocuses::Config::ManagerConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }

    assert_equal( 'rrdtool',        config.rrdtool_path )
    assert_equal( 300,              config.step )
    assert_equal( 600,              config.heartbeat )
    assert_equal( '/var/rocuses/rra', config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end

  must "parse manager config xml file" do
    test_xml = <<'END_XML'
<rocuses>
  <manager>
    <options>
      <rrdtool path="/usr/local/bin/rrdtool"/>
      <step time="60"/>
      <heartbeat step="300"/>
      <rra directory="/usr/local/rocuses/rra"/>
    </options>
  </manager>
</rocuses>
END_XML

    config = Rocuses::Config::ManagerConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }

    assert_equal( '/usr/local/bin/rrdtool', config.rrdtool_path )
    assert_equal( 60,                       config.step )
    assert_equal( 300,                      config.heartbeat )
    assert_equal( '/usr/local/rocuses/rra',   config.rra_directory )
    assert_equal( 500,              config.image_width )
    assert_equal( 120,              config.image_height )
  end
end
