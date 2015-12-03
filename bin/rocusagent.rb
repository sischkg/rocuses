#! /usr/bin/ruby2.1
# -*- coding: utf-8 -*-

require 'pp'
require 'optparse'
require 'rocuses/agent'

daemonize = false

require 'optparse'
OptionParser.new { |opt|
  opt.on('-f') {|v| daemonize = false }
  opt.on('-b') {|v| daemonize = true }

  opt.parse!(ARGV)
}


agentconfig = Rocuses::Config::AgentConfig.new
File.open( Rocuses::AgentParameters::AGENT_CONFIG_FILENAME ) { |configfile|
  agentconfig.load( configfile.gets( nil ) )
}
http_server = Rocuses::HTTPServer.new( :agentconfig => agentconfig,
                                       :daemonize   => daemonize )
http_server.start

