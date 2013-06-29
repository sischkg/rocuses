# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class BindSocketIO
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%7.0lf'

      LINE_STYLE_OF = {
        'UDP/IPv4 sockets opened'          => { :color => '#ff0000', :daches => false, :priority => 100, },
        'UDP/IPv6 sockets opened'          => { :color => '#ff0000', :daches => true,  :priority => 101, },
        'TCP/IPv4 sockets opened'          => { :color => '#00ff00', :daches => false, :priority => 110, },
        'TCP/IPv6 sockets opened'          => { :color => '#00ff00', :daches => true,  :priority => 111, },
        'UDP/IPv4 sockets closed'          => { :color => '#0000ff', :daches => false, :priority => 120, },
        'UDP/IPv6 sockets closed'          => { :color => '#0000ff', :daches => true,  :priority => 121, },
        'TCP/IPv4 sockets closed'          => { :color => '#ff00ff', :daches => false, :priority => 130, },
        'TCP/IPv6 sockets closed'          => { :color => '#ff00ff', :daches => true,  :priority => 131, },
        'UDP/IPv4 socket bind failures'    => { :color => '#ff00ff', :daches => false, :priority => 140, },
        'UDP/IPv6 socket bind failures'    => { :color => '#ff00ff', :daches => true,  :priority => 141, },
        'UDP/IPv4 socket connect failures' => { :color => '#990000', :daches => false, :priority => 150, },
        'UDP/IPv6 socket connect failures' => { :color => '#990000', :daches => true,  :priority => 151, },
        'UDP/IPv4 connections established' => { :color => '#009900', :daches => false, :priority => 161, },
        'UDP/IPv6 connections established' => { :color => '#009900', :daches => true,  :priority => 161, },
        'TCP/IPv4 connections established' => { :color => '#000099', :daches => false, :priority => 170, },
        'TCP/IPv6 connections established' => { :color => '#000099', :daches => true,  :priority => 171, },
        'TCP/IPv4 connections accepted'    => { :color => '#999900', :daches => false, :priority => 180, },
        'TCP/IPv6 connections accepted'    => { :color => '#999900', :daches => true,  :priority => 181, },
        'UDP/IPv4 send errors'             => { :color => '#009999', :daches => false, :priority => 190, },
        'UDP/IPv6 send errors'             => { :color => '#009999', :daches => true,  :priority => 191, },
        'UDP/IPv4 recv errors'             => { :color => '#990099', :daches => false, :priority => 200, },
        'UDP/IPv6 recv errors'             => { :color => '#990099', :daches => true,  :priority => 201, },
      }

      DEFAULT_LINE_STYLE = {
        :color => '#ffffff', :daches => false, :priority => 999999,
      }

      LINE_STYLE_OF.default = DEFAULT_LINE_STYLE

      def initialize( bind_datasource )
        @bind_datasource = bind_datasource
      end

      def name
        return 'bind_socket_io'
      end

      def category
        return "Bind"
      end

      def nodenames
        return [ @bind_datasource.nodename ]
      end

      def description
        return "Bind Socket IO Statistics - #{ @bind_datasource.nodename }"
      end

      def make_graph()
        title = description()

        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'count per second',
                                    :rigid          => false )

        @bind_datasource.socket_io_statistics_of.sort { |a,b|
          LINE_STYLE_OF[a[0]][:priority] <=> LINE_STYLE_OF[b[0]][:priority]
        }.each { |socket_io|
          key        = socket_io[0]
          count      = socket_io[1]
          line_style = LINE_STYLE_OF[key]

          Utils::draw_line( graph,
                            {
                              :label  => sprintf( '%20s', key ),
                              :value  => count,
                              :factor => 1,
                              :width  => 1,
                              :color  => line_style[:color],
                              :dashes => line_style[:dashes],
                              :format => GPRINT_FORMAT,
                            } )
        }
        return graph
      end
    end
  end
end

