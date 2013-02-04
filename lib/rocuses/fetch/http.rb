# -*- coding: utf-8 -*-

require 'net/http'

module Rocuses
  class Fetch
    class HTTP
      def initialize()
      end

      def fetch( target )
        return Net::HTTP.get( target.hostname, '/resource', target.port )
      end
    end
  end
end
