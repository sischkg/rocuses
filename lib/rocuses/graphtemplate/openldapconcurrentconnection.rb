# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate

    # OpenLDAPの同時接続数グラフテンプレート
    class OpenLDAPConcurrentConnection

      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%5.0lf'

      def initialize( openldap_datasource )
        @openldap_datasource = openldap_datasource
      end

      def category
        return "OpenLDAP"
      end

      def name
        return 'OpenLDAPConncurrentConnection'
      end

      def nodenames
        return [ @openldap_datasource.nodename ]
      end

      def description
        return "OpenLDAP Conncurent Connection - #{ @openldap_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'connection',
                                    :rigid          => false )

        Utils::draw_line( graph,
                          {
                            :label  => 'connection:          ',
                            :value  => @openldap_datasource.concurrent_connection,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'max file descriptor: ',
                            :value  => @openldap_datasource.max_file_descriptor,
                            :factor => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end
