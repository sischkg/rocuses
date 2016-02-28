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
          @graph_template_of[graph_template.graph_id] = graph_template
        end

        def get_graph_template( id )
          return @graph_template_of[id]
        end

        def list_nodes
          nodes = Array.new
          @graph_template_of.values.each { |graph_template|
            nodes += graph_template.nodenames
          }
          return nodes.sort.uniq
        end

        def find_graph_template_by_nodename( nodename )
          return @graph_template_of.find_all { |id, graph_template|
            graph_template.nodenames.include?( nodename )
          }
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

