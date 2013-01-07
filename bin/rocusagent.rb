#! /usr/bin/ruby1.9.1
# -*- coding: utf-8 -*-

require 'pp'
require 'optparse'
require 'rocuses/agent'

AGENT_CONFIG_FILE = '/etc/rocuses/agentconfig.xml'

daemonize = false

require 'optparse'
OptionParser.new { |opt|
  opt.on('-f') {|v| daemonize = false }
  opt.on('-b') {|v| daemonize = true }

  opt.parse!(ARGV)
}


agentconfig = Rocuses::Config::AgentConfig.new
File.open( AGENT_CONFIG_FILE ) { |configfile|
  agentconfig.load( configfile.gets( nil ) )
}
http_server = Rocuses::HTTPServer.new( :agentconfig => agentconfig,
                                       :daemonize   => daemonize )
http_server.start

