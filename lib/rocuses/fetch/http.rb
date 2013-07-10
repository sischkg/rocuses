# -*- coding: utf-8 -*-

require 'net/http'

module Rocuses
  class Fetch
    class HTTP
      def initialize()
      end

      def fetch( target )
        response = Net::HTTP.start( target.hostname, target.port ) { |http|
          http.get( '/resource' )
        }
        if response.code =~ /\A2../
          return response.body
        else
          raise "cannot get valid response from #{ target.hostname }:#{target.port}( #{ response.body } )"
        end
      end
    end
  end
end
