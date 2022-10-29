module ActiveRecordDecorator
  module ConditionAliasManager

    def self.get_operator_instance(operator_name)
      case operator_name.to_sym
      when :equal
        ActiveRecordDecorator::ConditionEvaluatorCore::Operators::Equal.new
      when :not_equal
        ActiveRecordDecorator::ConditionEvaluatorCore::Operators::NotEqual.new
      when :greater_than
        ActiveRecordDecorator::ConditionEvaluatorCore::Operators::GreaterThan.new
      when :lesser_than
        ActiveRecordDecorator::ConditionEvaluatorCore::Operators::LesserThan.new
      else
        raise 'Not implemented'
      end
    end

  end
end

