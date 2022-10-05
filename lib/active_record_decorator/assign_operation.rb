module ActiveRecordDecorator
  class AssignOperation

    attr_reader :record

    def initialize(record:)
      @record  = record
    end

    def method_missing(method, *args, &block)
      method = method.to_s
      (record.class.assign_operation_aliases || []).each do |op|
        if op.match?(method.to_sym)
          op.perform(record: @record, value: args.extract_options!.dup[:value] )
        end
      end
      @record
    end
  end
end