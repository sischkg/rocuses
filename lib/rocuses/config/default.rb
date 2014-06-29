# -*- coding: utf-8 -*-

module Rocuses
  module Config
    module Default
      BIND_PORT     = 20080;
      BIND_ADDRESS  = "0.0.0.0"
      AGENT_USER    = "rocus"
      AGENT_GROUP   = "rocus"
      MANAGER_USER  = "rocuses"
      MANAGER_GROUP = "rocuses"

      NAMED_STATISTICS_CHANNEL_ADDRESS = "127.0.0.1"
      NAMED_STATISTICS_CHANNEL_PORT    = 53
      NAMED_RNDC_PATH                  = "/usr/sbin/rndc"
      NAMED_STATS_PATH                 = "/var/named/named.stats"

      OPENLDAP_ADDRESS       = "127.0.0.1"
      OPENLDAP_PORT          = 389
      OPENLDAP_BIND_DN       = "cn=admin,cn=monitor"
      OPENLDAP_BIND_PASSWORD = "secret"
    end
  end
end
