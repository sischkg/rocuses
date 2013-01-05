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


agentconfig = RPerf::Config::AgentConfig.new
File.open( AGENT_CONFIG_FILE ) { |configfile|
  agentconfig.load( configfile.gets( nil ) )
}
http_server = RPerf::HTTPServer.new( :agentconfig => agentconfig,
                                     :daemonize   => daemonize )
http_server.start

