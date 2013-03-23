# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate
    class Manager
      include Enumerable

      def initialize
        @graph_template_of = Hash.new
      end

      def add_graph_template( graph_template )
        @graph_template_of[graph_template.id] = graph_template
      end

      def get_graph_template( id )
        if @graph_template_of[nodename].key?( id )
          return @graph_template_of[id]
        end
        raise ArgumentError.new( %Q[GraphTemplate "#{ id }" dose not exist.] ) 
      end

      def each()
        if block_given?
          @graph_template_of.values.each { |graph_template|
            yield( graph_template )
          }
        else
          return @graph_template_of.values
        end
      end

    end
  end
end


