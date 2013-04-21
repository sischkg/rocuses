# -*- coding: utf-8 -*-

module Rocuses
  class Manager
    module GraphTemplate
      class Manager
        include Enumerable

        def initialize
          @graph_template_of = Hash.new
        end

        def add_graph_template( graph_template )
          @graph_templates_of[graph_template.name] = graph_template
        end

        def get_graph_template( name )
          if @graph_template_of.key?( name )
            return @graph_template_of[name]
          end
          raise ArgumentError.new( "#{ id } of #{ nodename } dose not exist." )               
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
end

