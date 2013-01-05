# -*- coding: utf-8 -*-

require 'test/unit'
require 'flexmock/test_unit'

module Test::Unit
  include FlexMock::TestCase

  class TestCase
    def self.must( name, &block )
      test_name = "test_#{name.gsub(/\s+/, '_' )}".to_sym
      defined = instance_method( test_name ) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method( test_name, &block )
      else
        define_method( test_name ) do
          flunk "no implementation provided for #{name}"
        end
      end
    end

    def generate_popen_mock( args )
      io_mock = flexmock( IO )

      args.each { |command,output_lines|
        output = flexmock( command )
        output_lines_for_gets = output_lines.dup.push( nil )
        output.should_receive( :gets ).with_any_args.and_return( *output_lines_for_gets )
        output.should_receive( :each ).with( Proc ).and_return { |proc|
          output_lines.each { |line|
            proc.call( line )
          }
        }

        io_mock.should_receive( :popen ).
        with( command, Proc ).and_return { |str,proc|  proc.call( output ) } 
      }
      return io_mock
    end


    def generate_system_mock( args )
      mock = flexmock( Kernel )
      
      args.each { |cmd,result|
        mock.should_receive( :system ).with( cmd ).and_return( result )
      }
      return mock
    end

    def generate_executable_mock( args )
      mock = flexmock( FileTest )
      
      args.each { |path,result|
        mock.should_receive( :executable? ).with( path ).and_return( result )
      }
      return mock
    end

    def generate_readable_mock( args )
      mock_filetest = flexmock( FileTest )
      mock_file = flexmock( File )
      
      args.each { |path,result|
        mock_filetest.should_receive( :readable? ).with( path ).and_return( result )
        mock_file.should_receive( :readable? ).with( path ).and_return( result )
      }
      return mock_filetest
    end

    def generate_read_mock( args ) 
      io_mock = flexmock( File )

      args.each { |path,output_lines|
        output = flexmock( path )
        output_lines_for_gets = output_lines.dup.push( nil )
        output.should_receive( :gets ).with( nil ).and_return( output_lines.join )
        output.should_receive( :gets ).with_no_args.and_return( *output_lines_for_gets )
        output.should_receive( :each ).with( Proc ).and_return {
          |proc|
          output_lines.each { |line| proc.call( line ) }
        }

        io_mock.should_receive( :open ).
        with( path, Proc ).and_return { |str,proc|  proc.call( output ) } 
      }
      return io_mock
    end
    
    def generate_time_mock( time )
      time_mock = flexmock( Time )
      time_mock.should_receive( :now ).with_no_args.and_return( time )
      return time_mock
    end
  end
end

module RPerf
  module Test

    def read_file( filename )
      return File.open( filename ).gets( nil )
    end

    module_function :read_file

  end
end

