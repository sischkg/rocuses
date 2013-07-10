# -*- coding: utf-8 -*-

require 'rocuses/rrdtool/rpn'
require 'rocuses/rrdtool/graph'
require 'rocuses/utils'
require 'rocuses/graphtemplate/utils'
require 'rocuses/graphtemplate/drawable'

module Rocuses
  module GraphTemplate
    class OpenLDAPCache
      include Rocuses::GraphTemplate
      include Rocuses::GraphTemplate::Drawable
      include Rocuses::Utils

      GPRINT_FORMAT = '%7.0lf'

      def initialize( openldap_cache_datasource )
        @openldap_cache_datasource = openldap_cache_datasource
      end

      def name
        return sprintf( 'openldap_cache_%s',
                        @openldap_cache_datasource.directory )
      end

      def category
        return "OpenLDAP"
      end

      def nodenames
        return [ @openldap_cache_datasource.nodename ]
      end

      def description
        return sprintf( "OpenLDAP Database Cache - %s of %s",
                        @openldap_cache_datasource.directory,
                        @openldap_cache_datasource.nodename )
      end

      def make_graph()
        title = description()

        graph = RRDTool::Graph.new( :title          => description(),
                                    :lower_limit    => 0,
                                    :vertical_label => 'count',
                                    :rigid          => false )

        Utils::draw_line( graph,
                          {
                            :label  => 'IDL Cache  ',
                            :value  => @openldap_cache_datasource.idl_cache,
                            :color  => '#0000ff',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'Entry Cache',
                            :value  => @openldap_cache_datasource.entry_cache,
                            :color  => '#00ff00',
                            :format => GPRINT_FORMAT,
                          } )
        Utils::draw_line( graph,
                          {
                            :label  => 'DN Cache   ',
                            :value  => @openldap_cache_datasource.dn_cache,
                            :color  => '#ff0000',
                            :format => GPRINT_FORMAT,
                          } )

        return graph
      end
    end
  end
end

