module ActiveRecordDecorator
  module ConditionEvaluatorCore
    module Operators
      class Operator

        def evaluate(value_1, value_2)
          raise 'Not implemented'
        end

      end

      class Equal < Operator
        def evaluate(value_1, value_2)
          value_1.value == value_2.value
        end
      end

    end
  end
end