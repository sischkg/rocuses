# -*- coding: utf-8 -*-

module Rocuses
  module Utils

    # メソッドの引数に使用するHashのキーの有無をチェックする
    # 必要なキーが存在しない場合、余分なキーが存在する場合は、例外を投げる。
    # hash:: チェック対象のhash
    # keys:: 必要なキー、Optionalなキーを記述するハッシュ
    #  :req, required:: 必要なキー
    #  :op, optional:: optionalな（存在しても、しなくてもよい）キー
    # default_value_of:: デフォルト値を指定するHash
    # name:: 例外のメッセージに追加する名前
    #
    #   args            = { :id => 'foo', :mail => 'bar@example.com', :password => 'hoge' }
    #
    #   check_args( args, { :id => :req, :mail => :op, :password => :req }, 'pop' )
    #     -> return args
    #
    #   check_args( args, { :id => :req, :password => :req }  )
    #     -> raise ArgumentError  ( キー:mail が余分 )
    #
    #   check_args( args, { :id => :req, :lastlogined => req, :password => :req }  )
    #     -> raise ArgumentError  ( キー:lastlogined が足りない )
    #
    #   check_args( args, { :id => :req, :lastlogined => :op, mail => :op, :password => :req }, { :lastlogined => Time.now  ) )
    #     -> return { :id => 'foo', :lastlogined => Time.now, mail => 'bar@example.com', :password => 'hoge' }
    #
    def check_args( hash, keys, default_value_of = nil, name = %q{} )
      if hash.nil?
        raise ArgumentError.new( "hash must not be nil" )
      end
      if keys.nil?
        raise ArgumentError.new( "keys must not be nil" )
      end

      errors = Array.new

      keys.each { |k,v|
        if  v != :req &&
            v != :required &&
            v != :op &&
            v != :optional
          raise ArgumentError.new( "invalid key type #{ k } => #{ v }" )
        end
      }

      keys.each { |key,type|
        if type == :required || type == :req
          if ! hash.key?( key )
            errors.push( %Q{key "#{ key }" dose not exist} )
          end
        end
      }

      hash.each { |k,v|
        if ! keys.key?( k )
          errors.push( %Q{unknown key "#{ k }" exists} )
        end
      }

      if ! errors.empty?
        msg = %Q{ #{ name } has key errors: }
        msg += errors.join( ', ' )
        raise ArgumentError.new( msg )
      end

      if ! default_value_of.nil?
        hash = fill_default_value( hash, default_value_of )
      end

      return hash
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

    def escape_name( name )
      return name.gsub( %r{[/ ]}, %q{_} )
    end

    module_function :check_args, :fill_default_value, :datetime_to_second, :escape_name
    
  end
end

