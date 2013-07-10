# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate

    # OpenLDAPの一秒間の接続数グラフテンプレート
    class OpenLDAPConnection

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
        return 'OpenLDAPConnection'
      end

      def nodenames
        return [ @openldap_datasource.nodename ]
      end

      def description
        return "OpenLDAP Connection - #{ @openldap_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'connection per second',
                                    :rigid          => false )

        Utils::draw_line( graph,
                          {
                            :label  => 'connection: ',
                            :value  => @openldap_datasource.total_connection,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        return graph
      end
    end
  end
end
