# -*- coding: utf-8 -*-

require 'rocuses/fetch/http'

module Rocuses
  class Fetch
    def initialize()
      @method_of = { 'http' => Rocuses::Fetch::HTTP.new }
    end

    def fetch( target )
      return @method_of['http'].fetch( target )
    end
  end
end

