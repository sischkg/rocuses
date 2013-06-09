# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  module GraphTemplate
    module Drawable
      def filename
        return Rocuses::Utils::escape_name( sprintf( "%s_%s", nodenames().join( %q{,} ), name() ) )
      end

      def graph_id
        return Rocuses::Utils::escape_name( sprintf( "%s_%s", nodenames().join( %q{,} ), name() ) )
      end
    end
  end
end

