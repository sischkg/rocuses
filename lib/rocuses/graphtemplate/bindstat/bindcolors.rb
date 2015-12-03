# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate
    module BindStat
      module BindColors

        LINE_STYLE_OF = {
          'A'        => { :color => '#ff0000', :daches => false, :priority => 100, },
          '!A'       => { :color => '#ff0000', :daches => true,  :priority => 101, },
          'PTR'      => { :color => '#00ff00', :daches => false, :priority => 110, },
          '!PTR'     => { :color => '#00ff00', :daches => true,  :priority => 111, },
          'MX'       => { :color => '#0000ff', :daches => false, :priority => 120, },
          '!MX'      => { :color => '#0000ff', :daches => true,  :priority => 121, },
          'NS'       => { :color => '#ff00ff', :daches => false, :priority => 130, },
          '!NS'      => { :color => '#ff00ff', :daches => true,  :priority => 131, },
          'AAAA'     => { :color => '#990000', :daches => false, :priority => 140, },
          '!AAAA'    => { :color => '#990000', :daches => true,  :priority => 141, },
          'TXT'      => { :color => '#770000', :daches => true,  :priority => 142, },
          '!TXT'     => { :color => '#770000', :daches => false, :priority => 143, },
          'SOA'      => { :color => '#770077', :daches => false, :priority => 150, },
          '!SOA'     => { :color => '#770077', :daches => true,  :priority => 151, },
          'CNAME'    => { :color => '#000000', :daches => false, :priority => 200, },
          'NXDOMAIN' => { :color => '#000000', :daches => true,  :priority => 211, },
          'DS'       => { :color => '#000099', :daches => false, :priority => 300, },
          '!DS'      => { :color => '#000099', :daches => true,  :priority => 301, },
          'NSEC'     => { :color => '#009900', :daches => false, :priority => 310, },
          '!NSEC'    => { :color => '#009900', :daches => true,  :priority => 311, },
          'DNSKEY'   => { :color => '#009999', :daches => false, :priority => 320, },
          '!DNSKEY'  => { :color => '#999900', :daches => true,  :priority => 321, },
          'RRSIG'    => { :color => '#990099', :daches => false, :priority => 330, },
          '!RRSIG'   => { :color => '#990099', :daches => true,  :priority => 331, },
          'DLV'      => { :color => '#999999', :daches => false, :priority => 340, },
          '!DLV'     => { :color => '#999999', :daches => true,  :priority => 341, },

          'QUERY' => { :color => '#ff0000', :daches => false, :priority => 100, },

          'QryRTT10'    => { :color => '#ff0000', :daches => false, :priority => 100, },
          'QryRTT100'   => { :color => '#990000', :daches => false, :priority => 101, },
          'QryRTT500'   => { :color => '#00ff00', :daches => false, :priority => 102, },
          'QryRTT800'   => { :color => '#009900', :daches => false, :priority => 103, },
          'QryRTT1600'  => { :color => '#0000ff', :daches => false, :priority => 104, },
          'QryRTT1600+' => { :color => '#000000', :daches => false, :priority => 105, },

          'Queries via IPv4'   => { :color => '#ff0000', :daches => false, :priority => 100, },
          'Queries via IPv6'   => { :color => '#0000ff', :daches => true,  :priority => 101, },
          'Responses via IPv4' => { :color => '#ff0000', :daches => false, :priority => 110, },
          'Responses via IPv6' => { :color => '#0000ff', :daches => true,  :priority => 111, },

          'NXDOMAIN'   => { :color => '#ff0000', :daches => false, :priority => 100, },
          'SERVFAIL'   => { :color => '#00ff00', :daches => false, :priority => 110, },
          'FORMERR'    => { :color => '#0000ff', :daches => false, :priority => 120, },
          'OtherError' => { :color => '#000000', :daches => false, :priority => 130, },
          'EDNS0Fail'  => { :color => '#990000', :daches => false, :priority => 200, },
          'Mismatch'   => { :color => '#009900', :daches => false, :priority => 210, },
          'Truncated'  => { :color => '#000099', :daches => false, :priority => 220, },
          'Lame'       => { :color => '#009999', :daches => false, :priority => 230, },

        }

        DEFAULT_LINE_STYLE = {
          :color => '#cccccc', :daches => false, :priority => 999999,
        }

        def line_style_of( rrset )
          if LINE_STYLE_OF.key?( rrset )
            return LINE_STYLE_OF[rrset]
          end
          return DEFAULT_LINE_STYLE
        end

        module_function :line_style_of
      end
    end
  end
end

