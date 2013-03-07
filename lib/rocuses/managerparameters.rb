# -*- coding: utf-8 -*-

module Rocuses
  module ManagerParameters

    MANAGER_CONFIG_FILENAME = '/etc/rocuses/managerconfig.xml'
    TARGETS_CONFIG_FILENAME = '/etc/rocuses/targetsconfig.xml'

    SERIALIZE_DEVICES_FILENAME         = '/var/rocuses/data/devices.yaml'
    SERIALIZE_GRAPH_TEMPLATES_FILENAME = '/var/rocuses/data/graph_templates.yaml'

    GRAPH_TIME_PERIOD_OF = {
      :hourly  => 60 * 60,
      :daily   => 60 * 60 * 24,
      :weekly  => 60 * 60 * 24 * 7,
      :monthly => 60 * 60 * 24 * 31,
      :yearly  => 60 * 60 * 24 * 365,
    }


    SKIP_FILESYSTEMS = [
                        %r{\A/run},
                        %r{\A/dev},
                        %r{\A/media},
                       ]

  end
end

