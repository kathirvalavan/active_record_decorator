module ActiveRecordDecorator
  module ConditionEvaluatorCore
    class ValueObject

      attr_accessor :value

      def initialize(value)
        @value = value
      end

    end
  end
end