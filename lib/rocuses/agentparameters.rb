# -*- coding: utf-8 -*-

module Rocuses
  module AgentParameters

    AGENT_CONFIG_FILENAME = '/etc/rocuses/agentconfig.xml'
    LOG_DIRECTORY         = '/var/log/rocus'

    SKIP_FILESYSTEMS_ON_LINUX = [
                                 %r{\A/run/},
                                 %r{\A/run\z},
                                 %r{\A/dev/^(shm)},
                                 %r{\A/dev\z},
                                 %r{\A/media/},
                                 %r{\A/media\z},
                                 %r{\A/sys/},
                                ]

    SKIP_NETWORK_INTERFACES_ON_LINUX = [
                                        %r{\Alo\z},
                                       ]

    SKIP_DISK_IO_DEVICES_ON_LINUX = [
                                     %r{\Aram\d+\z},
                                     %r{\Aloop\d+\z},
                                     %r{\Asr\d+\z},
                                    ]

  end
end

