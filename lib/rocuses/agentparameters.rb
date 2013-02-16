# -*- coding: utf-8 -*-

module Rocuses
  module AgentParameters

    AGENT_CONFIG_FILENAME = '/etc/rocuses/agentconfig.xml'

    SKIP_FILESYSTEMS_ON_LINUX = [
                        %r{\A/run/},
                        %r{\A/dev/^(shm)},
                        %r{\A/media/},
                        %r{\A/sys/},
                       ]

    SKIP_NETWORK_INTERFACES_ON_LINUX = [
                                        %r{\Alo\z},
                                       ]

  end
end

