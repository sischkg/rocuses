# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate

    # OpenLDAPのOperation数グラフテンプレート
    class OpenLDAPOperation

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
        return 'OpenLDAPOperation'
      end

      def nodenames
        return [ @openldap_datasource.nodename ]
      end

      def description
        return "OpenLDAP Operation - #{ @openldap_datasource.nodename }"
      end

      def make_graph()
        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'operation',
                                    :rigid          => false )

        Utils::draw_area( graph,
                          {
                            :label  => 'bind:    ',
                            :value  => @openldap_datasource.bind_operation,
                            :factor => 1,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'unbind:  ',
                            :value  => @openldap_datasource.unbind_operation,
                            :factor => 1,
                            :color  => '#9999ff',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'search:  ',
                            :value  => @openldap_datasource.search_operation,
                            :factor => 1,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'compare: ',
                            :value  => @openldap_datasource.compare_operation,
                            :factor => 1,
                            :color  => '#99ff99',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'modify:  ',
                            :value  => @openldap_datasource.modify_operation,
                            :factor => 1,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'modrdn:  ',
                            :value  => @openldap_datasource.modrdn_operation,
                            :factor => 1,
                            :color  => '#ff9999',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'add:     ',
                            :value  => @openldap_datasource.add_operation,
                            :factor => 1,
                            :color  => '#ff00ff',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'delete:  ',
                            :value  => @openldap_datasource.delete_operation,
                            :factor => 1,
                            :color  => '#ff99ff',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'abandon: ',
                            :value  => @openldap_datasource.abandon_operation,
                            :factor => 1,
                            :color  => '#00ffff',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
        Utils::draw_area( graph,
                          {
                            :label  => 'extended:',
                            :value  => @openldap_datasource.extended_operation,
                            :factor => 1,
                            :color  => '#99ffff',
                            :format => GPRINT_FORMAT,
                            :stack  => true,
                          } )
      end
    end
  end
end
