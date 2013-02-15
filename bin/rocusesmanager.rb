#! /usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rocuses/manager'

manager = Rocuses::Manager.new
manager.fetch_resource()
manager.draw_graph()
