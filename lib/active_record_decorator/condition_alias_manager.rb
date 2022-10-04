module ActiveRecordDecorator
  module ConditionAliasManager

    def self.get_operator_instance(operator_name)
      case operator_name.to_sym
      when :equal
        ActiveRecordDecorator::ConditionEvaluatorCore::Operators::Equal.new
      else
        raise 'Not implemented'
      end
    end

  end
end

