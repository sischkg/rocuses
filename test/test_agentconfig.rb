# -*- coding: utf-8 -*-

$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'rocuses/test'
require 'rocuses/utils'
require 'rocuses/config/agentconfig'

class LoadXMLTest < Test::Unit::TestCase

  must "check_default_values" do
    config = Rocuses::Config::AgentConfig.new
    assert_equal( '/usr/sbin/rndc',         config.named.rndc_path )
    assert_equal( '/var/named/named.stats', config.named.stats_path )
    assert_equal( 'sendmail',               config.mta_type )
    assert_equal( '/usr/bin/mailq',         config.mailq_path )
    assert_equal( 389,                      config.openldap.port )
    assert_equal( 'cn=admin,cn=monitor',    config.openldap.bind_dn )
    assert_equal( 'secret',                 config.openldap.bind_password )
    assert_equal( '0.0.0.0',                config.bind_address )
    assert_equal( 20080,                    config.bind_port )
    assert_equal( 'rocus',                  config.user )
    assert_equal( 'rocus',                  config.group )
  end

  must "parse empty xml file" do
    test_xml = "<rocuses><agent><options></options></agent></rocuses>"
    config = Rocuses::Config::AgentConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    assert_equal( '/usr/sbin/rndc',         config.named.rndc_path )
    assert_equal( '/var/named/named.stats', config.named.stats_path )
    assert_equal( 'sendmail',               config.mta_type )
    assert_equal( '/usr/bin/mailq',         config.mailq_path )
    assert_equal( 389,                      config.openldap.port )
    assert_equal( 'cn=admin,cn=monitor',    config.openldap.bind_dn )
    assert_equal( 'secret',                 config.openldap.bind_password )
    assert_equal( '0.0.0.0',                config.bind_address )
    assert_equal( 20080,                    config.bind_port )
    assert_equal( 'rocus',                  config.user )
    assert_equal( 'rocus',                  config.group )
  end

  must "parse xml file" do
    test_xml = <<'END_XML'
<rocuses>
  <agent>
    <manager hostname="127.0.0.1"/>
    <manager hostname="192.168.0.1"/>
    <bind address="192.168.0.100" port="10080"/>
    <user name="rocususer"/>
    <group name="rocusgroup"/>
    <options>
      <mta type="postfix"/>
      <mailq path="/usr/local/postfix/bin/mailq"/>
      <openldap address="127.0.0.2" port="10389" bind_dn="cn=manager,cn=monitor" bind_password="PASS"/>
      <named rndc_path="/usr/local/bind/sbin/rndc" stats_path="/var/named/chroot/var/named/named.stats"/>
    </options>
  </agent>
</rocuses>
END_XML

    config = Rocuses::Config::AgentConfig.new
    assert_nothing_raised {
      config.load( test_xml )
    }
    assert_equal( '127.0.0.1',                    config.managers[0] )
    assert_equal( '192.168.0.1',                  config.managers[1] )
    assert_equal( '192.168.0.100',                config.bind_address )
    assert_equal( '10080',                        config.bind_port )
    assert_equal( 'rocususer',                    config.user )
    assert_equal( 'rocusgroup',                   config.group )

    assert_equal( 'postfix',                      config.mta_type )
    assert_equal( '/usr/local/postfix/bin/mailq', config.mailq_path )

    assert_equal( '/usr/local/bind/sbin/rndc',               config.named.rndc_path )
    assert_equal( '/var/named/chroot/var/named/named.stats', config.named.stats_path )

    assert_equal( 10389,                          config.openldap.port )
    assert_equal( 'cn=manager,cn=monitor',        config.openldap.bind_dn )
    assert_equal( 'PASS',                         config.openldap.bind_password )

  end

end
