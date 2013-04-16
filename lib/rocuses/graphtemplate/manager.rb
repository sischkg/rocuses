# -*- coding: utf-8 -*-

module Rocuses
  class Manager
    module GraphTemplate
      class Manager

        def initialize
          @graph_templates_of = Hash.new { |hash, nodename|
            hash[nodename] = Hash.new
          }
        end

        def add_graph_template( nodename, graph_template )
          @graph_templates_of[nodename][graph_template.name] = graph_template
        end

        def get_graph_template( id, nodename = nil )
          if ! nodename.nil?
            if @graph_templates_of.key?( nodename ) && @graph_templates_of[nodename].key?( id )
              return @graph_templates_of[nodename][id]
            end
            raise ArgumentError.new( "#{ id } of #{ nodename } dose not exist." ) 
          else
            @graph_templates_of.each { |node, graph_template_of|
              if graph_template_of.key?( id )
                return graph_template_of[id]
              end
            }
            raise ArgumentError.new( "#{ id } of #{ nodename } dose not exist." )               
          end
        end

        def each()
          if block_given?
            @graph_templates_of.each { |nodename, graph_template_of_node|
              graph_template_of_node.each { |name, graph_template|
                yield( graph_template )
              }
            }
          else
            graph_templates = Array.new
            @graph_templates_of.values.each { |nodename, graph_template_of_node|
              graph_template_of_node.each { |id, graph_template|
                graph_templates << graph_template
              }
            }
            return graph_templates
          end
        end
      end

    end
  end
end

