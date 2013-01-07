# -*- coding: utf-8 -*-

module Rocuses
  module Utils

    # メソッドの引数に使用するHashのキーの有無をチェックする
    # 必要なキーが存在しない場合、余分なキーが存在する場合は、例外を投げる。
    # args:: チェック対象のhash
    # key_of:: 必要なキー、Optionalなキーを記述するハッシュ
    #  :req, required:: 必要なキー
    #  :op, optional:: optionalな（存在しても、しなくてもよい）キー
    # name:: 例外のメッセージに追加する名前
    #
    # args = { :id => 'foo', :mail => 'bar@example.com', :password => 'hoge' }
    #
    # check_hash( args, { :id => :req, :mail => :op, :password => :req }, 'pop' )
    #   -> return
    #
    # check_hash( args, { :id => :req, :password => :req }, 'pop'  )
    #   -> raise ArgumentError  ( キー:mail が余分 )
    #
    # check_hash( args, { :id => :req, :mail => op }, 'pop'  )
    #   -> raise ArgumentError  ( キー:password が足りない )
    #
    def check_args( args, key_of, name = %q{} )
      if args.nil?
        raise ArgumentError.new( "args must not be nil" )
      end
      if key_of.nil?
        raise ArgumentError.new( "key_of must not be nil" )
      end

      errors = Array.new
      key_of.each { |k,v|
        if  v != :req &&
            v != :required &&
            v != :op &&
            v != :optional
          raise ArgumentError.new( "invalid key type #{ k } => #{ v }" )
        end
      }

      key_of.each { |key,type|
        if type == :required || type == :req
          if ! args.key?( key )
            errors.push( %Q{key "#{ key }" dose not exist} )
          end
        end
      }

      args.each { |k,v|
        if ! key_of.key?( k )
          errors.push( %Q{unknown key "#{ k }" exists} )
        end
      }

      return if errors.empty?

      msg = %Q{ #{ name } has key errors: }
      msg += errors.join( ', ' )

      raise ArgumentError.new( msg )
    end

    def fill_default_value( args, default_value_of )
      if args.nil?
        raise ArgumentError.new( "args must not be nil" )
      end
      if default_value_of.nil?
        raise ArgumentError.new( "default_value_of must not be nil" )
      end

      new_args = args.dup
      default_value_of.each { |k,v|
        if ! new_args.key?( k )
          new_args[k] = v
        end
      }
      return new_args
    end

    def datetime_to_second( args )
      check_args( args, 
                  {
                    :day    => :op,
                    :hour   => :op,
                    :minute => :op,
                    :second => :op,
                  } )

      args = fill_default_value( args, 
                                 {
                                   :day    => 0,
                                   :hour   => 0,
                                   :minute => 0,
                                   :second => 0,
                                 } )
      return ( ( args[:day].to_i * 24 + args[:hour].to_i ) * 60 + args[:minute].to_i ) * 60  + args[:second].to_i
    end

    module_function :check_args, :fill_default_value, :datetime_to_second
    
  end
end

