# -*- coding: utf-8 -*-

module Rocuses
  module GraphTemplate
    module BindStat
      module BindColors

        module_function

        def line_style_of_rr_type( rr_type )
          return line_style_of( LINE_STYLE_OF_RR_TYPE, rr_type )
        end

        def line_style_of_request_opcode( opcode )
          return line_style_of( LINE_STYLE_OF_REQUEST_OPCODE, opcode )
        end

        def description_of_request_opcode( opcode )
          return description_of( LINE_STYLE_OF_REQUEST_OPCODE, opcode )
        end

        def line_style_of_rtt( symbol )
          return line_style_of( LINE_STYLE_OF_RTT, symbol )
        end

        def description_of_rtt( symbol )
          return description_of( LINE_STYLE_OF_RTT, symbol )
        end

        def line_style_of_query_response_by_resolver( symbol )
          return line_style_of( LINE_STYLE_OF_QUERY_RESPONSE_BY_RESOLVER, symbol )
        end

        def description_of_query_response_by_resolver( symbol )
          return description_of( LINE_STYLE_OF_QUERY_RESPONSE_BY_RESOLVER, symbol )
        end

        def line_style_of_received_error_by_resolver( symbol )
          return line_style_of( LINE_STYLE_OF_RECEIVED_ERROR_BY_RESOLVER, symbol )
        end

        def description_of_received_error_by_resolver( symbol )
          return description_of( LINE_STYLE_OF_RECEIVED_ERROR_BY_RESOLVER, symbol )
        end

        def line_style_of_resolver_error_by_resolver( symbol )
          return line_style_of( LINE_STYLE_OF_RESOLVER_ERROR_BY_RESOLVER, symbol )
        end

        def description_of_resolver_error_by_resolver( symbol )
          return description_of( LINE_STYLE_OF_RESOLVER_ERROR_BY_RESOLVER, symbol )
        end

        LINE_STYLE_OF_RR_TYPE = {
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
          'TXT'      => { :color => '#770000', :daches => false, :priority => 142, },
          '!TXT'     => { :color => '#770000', :daches => true,  :priority => 143, },
          'SOA'      => { :color => '#770077', :daches => false, :priority => 150, },
          '!SOA'     => { :color => '#770077', :daches => true,  :priority => 151, },
          'CNAME'    => { :color => '#000000', :daches => false, :priority => 200, },
          'NXDOMAIN' => { :color => '#000000', :daches => true,  :priority => 211, },
          'DS'       => { :color => '#000099', :daches => false, :priority => 300, },
          '!DS'      => { :color => '#000099', :daches => true,  :priority => 301, },
          'NSEC'     => { :color => '#009900', :daches => false, :priority => 310, },
          '!NSEC'    => { :color => '#009900', :daches => true,  :priority => 311, },
          'DNSKEY'   => { :color => '#009999', :daches => false, :priority => 320, },
          '!DNSKEY'  => { :color => '#009999', :daches => true,  :priority => 321, },
          'RRSIG'    => { :color => '#990099', :daches => false, :priority => 330, },
          '!RRSIG'   => { :color => '#990099', :daches => true,  :priority => 331, },
          'DLV'      => { :color => '#cc0000', :daches => false, :priority => 340, },
          '!DLV'     => { :color => '#cc0000', :daches => true,  :priority => 341, },
          'SRV'      => { :color => '#00cc00', :daches => false, :priority => 350, },
          '!SRV'     => { :color => '#00cc00', :daches => false, :priority => 351, },
          'SPF'      => { :color => '#0000cc', :daches => false, :priority => 360, },
          '!SPF'     => { :color => '#0000cc', :daches => false, :priority => 361, },
          'IXFR'     => { :color => '#cc00cc', :daches => false, :priority => 370, },
          'ANY'      => { :color => '#cccc00', :daches => false, :priority => 380, },
        }

        LINE_STYLE_OF_REQUEST_OPCODE = {
          'QUERY'  => { :color => '#ff0000', :daches => false, :priority => 100, },
          'IQUERY' => { :color => '#00ff00', :daches => false, :priority => 110, },
          'NOTIFY' => { :color => '#0000ff', :daches => false, :priority => 120, },
        }

        LINE_STYLE_OF_RTT = {
          'QryRTT10'    => { :color => '#ff0000', :daches => false, :priority => 100, :description => '   0ms < rtt <   10ms' },
          'QryRTT100'   => { :color => '#990000', :daches => false, :priority => 101, :description => '  10ms < rtt <  100ms' },
          'QryRTT500'   => { :color => '#00ff00', :daches => false, :priority => 102, :description => ' 100ms < rtt <  500ms' },
          'QryRTT800'   => { :color => '#009900', :daches => false, :priority => 103, :description => ' 500ms < rtt <  800ms' },
          'QryRTT1600'  => { :color => '#0000ff', :daches => false, :priority => 104, :description => ' 800ms < rtt < 1600ms' },
          'QryRTT1600+' => { :color => '#000000', :daches => false, :priority => 105, :description => '1600ms < rtt         ' },
        }

        LINE_STYLE_OF_QUERY_RESPONSE_BY_RESOLVER = {
          'Queryv4'    => { :color => '#ff0000', :daches => false, :priority => 100, :description => 'Queries via IPv4'   },
          'Queryv6'    => { :color => '#0000ff', :daches => false, :priority => 101, :description => 'Queries via IPv6'   },
          'Responsev4' => { :color => '#ff0000', :daches => true,  :priority => 110, :description => 'Responses via IPv4' },
          'Responsev6' => { :color => '#0000ff', :daches => true,  :priority => 111, :description => 'Responses via IPv6' },
        }

        LINE_STYLE_OF_RECEIVED_ERROR_BY_RESOLVER = {
          'NXDOMAIN'   => { :color => '#ff0000', :daches => false, :priority => 100, },
          'SERVFAIL'   => { :color => '#00ff00', :daches => false, :priority => 110, },
          'FORMERR'    => { :color => '#0000ff', :daches => false, :priority => 120, },
          'OtherError' => { :color => '#000000', :daches => false, :priority => 130, },
          'EDNS0Fail'  => { :color => '#990000', :daches => false, :priority => 130, },
          'Mismatch'   => { :color => '#009900', :daches => false, :priority => 210, },
          'Truncated'  => { :color => '#000099', :daches => false, :priority => 220, },
        }

        LINE_STYLE_OF_RESOLVER_ERROR_BY_RESOLVER = {
          'Lame'          => { :color => '#990000', :daches => false, :priority => 200, },
          'Retry'         => { :color => '#009900', :daches => false, :priority => 210, },
          'QueryAbort'    => { :color => '#000099', :daches => false, :priority => 220, },
          'QuerySockFail' => { :color => '#009999', :daches => false, :priority => 230, },
          'QueryTimeout'  => { :color => '#999900', :daches => false, :priority => 230, },
        }
       
        DEFAULT_LINE_STYLE = {
          :color => '#cccccc', :daches => false, :priority => 999999,
        }

        def line_style_of( category, type )
          if category.key?( type )
            return category[type]
          else
            return DEFAULT_LINE_STYLE
          end
        end

        def description_of( category, type )
          style = line_style_of( category, type )
          if style.key?( :description )
            return style[:description]
          else
            return type
          end
        end
      end
    end
  end
end

