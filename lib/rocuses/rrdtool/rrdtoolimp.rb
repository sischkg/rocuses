# -*- coding: utf-8 -*-

require 'open3'
require 'singleton'
require 'rocuses/utils'
require 'pp'

module Rocuses
  module RRDTool
    class RRDToolImp
      include Rocuses
      include Singleton

      attr_accessor :rrdtool_path

      def initialize
        @name_index     = 0
        @rrdtool_path   = 'rrdtool'
        @rrd_store_path = '/var/rrd'
      end

      def set_parameters( args )
        if args.key?( :rrdtoo_path )
          @rrdtool_path = args[:rrdtool_path]
        end
        if args.key?( :rrd_store_path )
          @rrd_store_path = args[:rrd_store_path]
        end
      end

      def assign_name
        @name_index += 1
        return sprintf( 'rpn_%05d', @name_index )
      end

      def create( cmd )
        open()
        @stdin.print( "create #{ cmd }\n" )
        parse_result( @stdin, @stdout )
      end

      def update( cmd )
        open()

        @stdin.print( "update #{ cmd }\n" )
        parse_result( @stdin, @stdout )
      end

      def draw( cmd )
        open()

        @stdin.print( "graphv -  --imgformat PNG #{ cmd }\n" )
        return parse_draw_result( cmd, @stdin, @stdout )
      end

      def close
        if ! @stdin.nil?
          @stdin.print( "quit\n" )
          @stdin.close
          @stdout.close
          @stderr.close
        end
      end

      def rrd_filename( datasource )
        return sprintf( "%s/%s.rrd", @rrd_store_path, datasource.name() )
      end

      private

      def open()
        if @stdin.nil?
          @stdin, @stdout, @stderr = *Open3.popen3( @rrdtool_path, '-' )
          @stdin.sync = true
          @stdout.sync = true
        end
      end

      def parse_result( output, input )
        while line = input.readline
          pp line
          if line =~ /\AOK/
            return
          elsif line =~ /\AERROR/
            output.print( "\n" )
          end
        end
      end

      def parse_draw_result( cmd, output, input )
        image = nil
        error_lines = %q{}
        error_flag = false

        while line = input.readline
          line.chomp!
          if line =~ /\AOK/
            break
          elsif line =~ /\AERROR/
            output.print( "\n" )
            error_lines += line
            error_lines += "\n"
            error_flag = true
          elsif error_flag
            next
          elsif line =~ /\Aimage = BLOB_SIZE:(\d+)/
            length = $1.to_i
            image = input.read( length )
          end
        end

        if error_flag
          raise %Q[cannot draw graph: "#{ cmd }"( #{error_lines} )]
        end    
        if image.nil?
          raise "cannot recieve image data from rrdtool graphv."
        end

        return image
      end
    end
  end
end