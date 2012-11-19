$LOAD_PATH.insert( 0, File.join( File.dirname( __FILE__ ), %q{..}, 'lib' ) )

require 'rperf/utils'
require 'rperf/test'

class TestUtils < Test::Unit::TestCase

  must "required test ok" do
    args = { :arg1 => 'required' }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg1 => :req } )
    }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg1 => :required } )
    }
  end

  must "optional test ok" do
    args = { :arg2 => 'optional' }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg2 => :op } )
    }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg2 => :optional } )
    }
  end

  must "required and optional keys ok" do
    args = { :arg1 => 'required' }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg1 => :req } )
    }
    assert_nothing_raised {
      RPerf::Utils::check_args( args, { :arg1 => :req, :arg2 => :op } )
    }
  end

  must "unknown keys is detected" do
    args = { :arg0 => 'unkown' }
    assert_raise( ArgumentError ) {
      RPerf::Utils::check_args( args, { :arg2 => :op } )
    }
  end

  must "invalid key type error detected" do
    assert_raise( ArgumentError ) {
      RPerf::Utils::check_args( { :arg0 => 'required' }, { :arg0 => :none } )
    }
  end

  must "valid keys" do
    assert_nothing_raised {
      RPerf::Utils::check_args( { :arg0 => 'required' }, { :arg0 => :req, :arg1 => :optional } )
    }
  end

  must "raise ArgumentError if hash is nil" do
    assert_raise( ArgumentError ) {
      RPerf::Utils::check_args( nil, { :arg0 => :req, :arg1 => :optional } )
    }
  end

  must "raise ArgumentError if keys is nil" do
    assert_raise( ArgumentError ) {
      RPerf::Utils::check_args( { :arg0 => 'test' }, nil )
    }
  end

  must "fill default values" do
    args             = { :arg1 => 'no default 1', :arg2 => 'default 2' }
    default_value_of = {                          :arg2 => 'set default value 2', :arg3 => 'set default value 3' }
    
    new_args = RPerf::Utils::fill_default_value( args, default_value_of )
    assert_equal( args[:arg1],             new_args[:arg1], 'arg1 was not changed' )
    assert_equal( args[:arg2],             new_args[:arg2], 'arg2 was not changed' )
    assert_equal( default_value_of[:arg3], new_args[:arg3], 'arg3 was set default value' )
  end

  must "raise argument error, if args is nill" do
    assert_raise( ArgumentError ) {
      RPerf::Utils::fill_default_value( nil, {} )
    }
  end

  must "raise argument error, if default_value_of is nill" do
    assert_raise( ArgumentError ) {
      RPerf::Utils::fill_default_value( {}, nil )
    }
  end

end

