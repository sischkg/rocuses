# -*- coding: utf-8 -*-

module Rocuses
  module ManagerParameters

    MANAGER_CONFIG_FILENAME = '/etc/rocuses/managerconfig.xml'
    TARGETS_CONFIG_FILENAME = '/etc/rocuses/targetsconfig.xml'

    GRAPH_TIME_PERIOD_OF = {
      :hourly  => 60 * 60,
      :daily   => 60 * 60 * 24,
      :weekly  => 60 * 60 * 24 * 7,
      :monthly => 60 * 60 * 24 * 31,
      :yearly  => 60 * 60 * 24 * 365,
    }

  end
end

