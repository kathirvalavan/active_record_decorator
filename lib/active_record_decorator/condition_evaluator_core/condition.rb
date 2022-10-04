module ActiveRecordDecorator
  module ConditionEvaluatorCore
    class Condition
      attr_accessor :attr, :operator, :name

      def initialize(name, attr, operator, value)
        @name = name
        @attr = attr
        @operator = operator || :equal
        @value   = value
      end

      def evaluate(record)
        record_value = record.send(@attr)
        ActiveRecordDecorator::ConditionAliasManager.get_operator_instance(@operator).evaluate(ValueObject.new(record_value), ValueObject.new(@value))
      end

      def condition_match?(condition_name)
        condition_name == @name
      end
    end
  end
end