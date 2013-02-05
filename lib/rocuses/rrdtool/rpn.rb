# -*- coding: utf-8 -*-

require 'rocuses/utils'

module Rocuses
  module RRDTool

    module RPN_Base
      def *( rhs )
        return RPN_Multiple.new( self, rhs.to_rpn )
      end

      def +( rhs )
        return RPN_Plus.new( self, rhs.to_rpn )
      end

      def -( rhs )
        return RPN_Minus.new( self, rhs.to_rpn )
      end

      def /( rhs )
        return RPN_Div.new( self, rhs.to_rpn )
      end

      def coerce( other )
        [ Fixnum, Integer, Bignum, Float ].each { |type|
          if other.kind_of?( type ) 
            return [ RPN_Constant.new( other ), self ]
          end
        }
        return super
      end

      def to_vdef
        return RPN_Value.new( self, true )
      end

      def to_cdef
        return RPN_Value.new( self, false )
      end
    end

    class RPN_UnaryOperator
      AVAILABLE_OPERATORS = [ :AVERAGE, :MAXIMUM, :MINIMUM, :LAST ]

      include RPN_Base

      def to_rpn
        self
      end

      attr_reader :name, :is_vdef

      def initialize( arg, op, is_vdef  )
        @arg            = arg.to_rpn
        @operator       = op
        @name           = RRDTool.assign_name()
        @tmp_value_name = RRDTool.assign_name()
        @is_vdef        = is_vdef

        if ! AVAILABLE_OPERATORS.include?( @operator )
          raise ArgumentError.new( %Q[cannot use operator("#{@operator}") ] )
        end
      end

      def depend_on
        return @arg.depend_on + [ self ]
      end

      def definition
        return sprintf( "CDEF:%s=%s VDEF:%s=%s,%s",
                        @tmp_value_name,
                        @arg.rpn_expression(),
                        @name, 
                        @tmp_value_name,
                        @operator )
#        return sprintf( "%sDEF:%s=%s %sDEF:%s=%s,%s",
#                        @arg.is_vdef() ? 'V' : 'C',
#                        @tmp_value_name,
#                        @arg.rpn_expression(),
#                        @is_vdef ? 'V' : 'C',
#                        @name, 
#                        @tmp_value_name,
#                        @operator )
      end

      def rpn_expression
        return @name
      end
    end

    class RPN_BinaryOperator
      AVAILABLE_OPERATORS = [ '+', '-', '*', '/', ]

      include RPN_Base

      attr_reader :name

      def to_rpn
        self
      end

      def initialize( lhs, rhs, op )
        @name      = RRDTool.assign_name()
        @lhs       = lhs.to_rpn
        @rhs       = rhs.to_rpn
        @operator  = op
        if ! AVAILABLE_OPERATORS.include?( @operator )
          raise ArgumentError.new( %Q[cannot use operator("#{@operator}") ] )
        end
      end

      def depend_on
        return @lhs.depend_on() + @rhs.depend_on() + [ self ]
      end

      def definition
        return sprintf( "CDEF:%s=%s,%s,%s",
#                        is_vdef() ? 'V' : 'C',
                        @name,
                        @lhs.rpn_expression(),
                        @rhs.rpn_expression(),
                        @operator )
      end

      def rpn_expression
        return @name
      end

      def is_vdef
        return false
      end

    end

    class RPN_Value < Numeric

      include RPN_Base

      def to_rpn
        self
      end

      attr_reader :name

      attr_reader :is_vdef

      def initialize( arg, type = false )
        @arg     = arg.to_rpn
        @is_vdef = type
        @name    = RRDTool.assign_name()
      end

      def depend_on
        return @arg.depend_on() + [ self ]
      end

      def definition
        if @is_vdef
          return sprintf( 'VDEF:%s=%s,AVERAGE',
                          @name,
                          @arg.rpn_expression() )
        else
          return sprintf( 'CDEF:%s=%s',
                          @name,
                          @arg.rpn_expression() )
        end
      end

      def rpn_expression
        return @name
      end
    end


    class RPN_DataSource < Numeric
      AVAILABLE_CF = [ :AVERAGE, :MAX, :MIN, :LAST ]

      include RPN_Base

      def to_rpn
        self
      end

      attr_reader :datasrouce, :type, :name

      def initialize( datasource, type )
        @datasource = datasource
        @type       = type
        if ! AVAILABLE_CF.include?( @type )
          raise ArgumentError.new( %Q[invalid CF type "#{@type}"] )
        end
        @name = RRDTool.assign_name()
      end

      def depend_on
        return [ self ]
      end

      def definition
        return sprintf( "DEF:%s=%s:value:%s", @name, @datasource.filename, @type )
      end

      def rpn_expression()
        return @name
      end

      def is_vdef
        return false
      end
    end

    class RPN_Constant < Numeric
      include RPN_Base

      def to_rpn
        self
      end

      def initialize( value )
        @value = value
      end

      def depend_on
        return []
      end

      def definition
        return %q{}
      end

      def rpn_expression()
        return @value.to_s
      end

      def is_vdef
        return true
      end
    end

    class RPN_Plus < RPN_BinaryOperator
      def initialize( lhs, rhs )
        super( lhs, rhs, '+' )
      end
    end

    class RPN_Multiple < RPN_BinaryOperator
      def initialize( lhs, rhs )
        super( lhs, rhs, '*' )
      end
    end

    class RPN_Plus < RPN_BinaryOperator
      def initialize( lhs, rhs )
        super( lhs, rhs, '+' )
      end
    end

    class RPN_Minus < RPN_BinaryOperator
      def initialize( lhs, rhs )
        super( lhs, rhs, '-' )
      end
    end

    class RPN_Div < RPN_BinaryOperator
      def initialize( lhs, rhs )
        super( lhs, rhs, '/' )
      end
    end

    class RPN_Average < RPN_UnaryOperator
      def initialize( arg )
        super( arg, :AVERAGE, true )
      end
    end

    class RPN_Maximum < RPN_UnaryOperator
      def initialize( arg )
        super( arg, :MAXIMUM, true )
      end
    end

    class RPN_Minimum < RPN_UnaryOperator
      def initialize( arg )
        super( arg, :MINIMUM, true )
      end
    end

    class RPN_Last < RPN_UnaryOperator
      def initialize( arg )
        super( arg, :LAST, true )
      end
    end

  end
end

class Integer
  def to_rpn
    return Rocuses::RRDTool::RPN_Constant.new( self )
  end
end

class Float
  def to_rpn
    return Rocuses::RRDTool::RPN_Constant.new( self )
  end
end

class Fixnum
  def to_rpn
    return Rocuses::RRDTool::RPN_Constant.new( self )
  end
end

class Bignum
  def to_rpn
    return Rocuses::RRDTool::RPN_Constant.new( self )
  end
end

