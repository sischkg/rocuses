# -*- coding: utf-8 -*-

require 'pp'
require 'rocuses/resource'

module Rocuses
  class Agent
    class NoOS

      def initialize( agentconfig )
        return true
      end

      def name
        return "Rocuses::Agent::NoOS"
      end

      # RETURN:: true
      def self.match_environment?( agentconfig )
        return true
      end

      # dummy
      def get_cpus( resource )
      end
 
      # dummy
      def get_cpu_average( resource )
      end

     # dummy
      def get_virtual_memory_status( resource )
      end

      # dummy
      def get_network_interface_status( resource )
      end

      # dummy
      def get_processes( resource )
      end

      # dummy
      def get_filesystem_status( resource )
      end

      # dummy
      def get_load_average( resource )
      end
    end
  end
end

