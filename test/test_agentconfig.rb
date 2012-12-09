# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'args/test'
require 'rperf/config/agentconfig'

class LoadXMLTest < Test::Unit::TestCase

  must "check_default_values" do
    config = RPerf::Config::AgentConfig.new
    assert_equal( config.rndc_path,        '/usr/sbin/rndc' )
    assert_equal( config.named_stats_path, '/var/named/named.stats' )
    assert_equal( config.mta_type,         'sendmail' )
    assert_equal( config.mailq_path,       '/usr/bin/mailq' )
  end

  must "parse empty xml file" do
    test_xml = "<perf><agent><options></options></agent></perf>"
    config = RPerf::Config::AgentConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    assert_equal( config.rndc_path,        '/usr/sbin/rndc' )
    assert_equal( config.named_stats_path, '/var/named/named.stats' )
    assert_equal( config.mta_type,         'sendmail' )
    assert_equal( config.mailq_path,       '/usr/bin/mailq' )
  end

  must "parse xml file" do
    test_xml = <<'END_XML'
<rperf>
  <agent>
    <manager hostname="127.0.0.1"/>
    <manager hostname="192.168.0.1"/>
    <options>
      <rndc path="/usr/local/bind/sbin/rndc"/>
      <named_stats path="/var/named/named.stats"/>
      <mta type="postfix"/>
      <mailq path="/usr/local/postfix/bin/mailq"/>
      <cpu_resource path="/tmp/resource"/>
    </options>
  </agent>
</rperf>
END_XML

    config = RPerf::Config::AgentConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    assert_equal( config.managers[0],      "127.0.0.1" )
    assert_equal( config.managers[1],      "192.168.0.1" )
    assert_equal( config.rndc_path,        '/usr/local/bind/sbin/rndc' )
    assert_equal( config.named_stats_path, '/var/named/named.stats' )
    assert_equal( config.mta_type,         'postfix' )
    assert_equal( config.mailq_path,       '/usr/local/postfix/bin/mailq' )
  end

end
