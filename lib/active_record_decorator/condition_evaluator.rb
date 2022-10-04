module ActiveRecordDecorator
  class ConditionEvaluator

    attr_reader :record, :condition_to_evaluate

    def initialize(record:, condition_to_evaluate:)
      @record  = record
      @condition_to_evaluate  = condition_to_evaluate
    end

    def evaluate
      value = nil
      @record.class.all_condition_aliases.each do |con|
        if con.condition_match?(@condition_to_evaluate)
          value = con.evaluate(@record)
        end
      end
      value
    end
  end
end