# -*- coding: utf-8 -*-

require 'pp'
require 'rperf/resource'

module RPerf
  class Agent
    class NoOS
      # RETURN:: true
      def self.match_environment?
        return true
      end

      # dummy
      def get_cpu_status( resource )
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

