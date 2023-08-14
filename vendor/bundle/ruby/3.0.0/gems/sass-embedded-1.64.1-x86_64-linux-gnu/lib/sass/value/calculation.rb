# frozen_string_literal: true

module Sass
  module Value
    # Sass's calculation type.
    #
    # @see https://sass-lang.com/documentation/js-api/classes/sasscalculation/
    class Calculation
      include Value
      include CalculationValue

      def initialize(name, arguments)
        @name = name.freeze
        @arguments = arguments.freeze
      end

      # @return [::String]
      attr_reader :name

      # @return [Array<CalculationValue>]
      attr_reader :arguments

      private_class_method :new

      class << self
        # @param argument [CalculationValue]
        # @return [Calculation]
        def calc(argument)
          argument.assert_calculation_value
          new('calc', [argument])
        end

        # @param arguments [Array<CalculationValue>]
        # @return [Calculation]
        def min(arguments)
          arguments.each(&:assert_calculation_value)
          new('min', arguments)
        end

        # @param arguments [Array<CalculationValue>]
        # @return [Calculation]
        def max(arguments)
          arguments.each(&:assert_calculation_value)
          new('max', arguments)
        end

        # @param min [CalculationValue]
        # @param value [CalculationValue]
        # @param max [CalculationValue]
        # @return [Calculation]
        def clamp(min, value = nil, max = nil)
          if (value.nil? && !valid_clamp_arg?(min)) ||
             (max.nil? && [min, value].none? { |x| x && valid_clamp_arg?(x) })
            raise Sass::ScriptError, 'Argument must be an unquoted SassString or CalculationInterpolation.'
          end

          arguments = [min]
          arguments.push(value) unless value.nil?
          arguments.push(max) unless max.nil?
          arguments.each(&:assert_calculation_value)
          new('clamp', arguments)
        end

        private

        def valid_clamp_arg?(value)
          value.is_a?(Sass::CalculationValue::CalculationInterpolation) ||
            (value.is_a?(Sass::Value::String) && !value.quoted?)
        end
      end

      # @return [Calculation]
      def assert_calculation(_name = nil)
        self
      end

      # @return [::Boolean]
      def ==(other)
        other.is_a?(Sass::Value::Calculation) &&
          other.name == name &&
          other.arguments == arguments
      end

      # @return [Integer]
      def hash
        @hash ||= [name, *arguments].hash
      end
    end
  end
end
