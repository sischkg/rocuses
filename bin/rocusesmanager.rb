#! /usr/bin/ruby1.8
# -*- coding: utf-8 -*-

require 'rocuses/manager'

manager = Rocuses::Manager.new
manager.fetch_resource()
manager.draw_graph()
