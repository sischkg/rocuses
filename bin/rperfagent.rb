#! /usr/bin/ruby1.8
# -*- coding: utf-8 -*-

require 'pp'
require 'optparse'
require 'rperf/agent'

AGENT_CONFIG_FILE = '/etc/rperf/agentconfig.xml'

daemonize = false

require 'optparse'
OptionParser.new { |opt|
  opt.on('-f') {|v| daemonize = false }
  opt.on('-b') {|v| daemonize = true }

  opt.parse!(ARGV)
}


agent_config = RPerf::Config::AgentConfig.new
File.open( AGENT_CONFIG_FILE ) { |configfile|
  agent_config.load( t = configfile.gets( nil ) )
  pp t
}
pp agent_config
http_server = RPerf::HTTPServer.new( :config    => agent_config,
                                     :daemonize => daemonize )
http_server.start

