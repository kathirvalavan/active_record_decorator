module ActiveRecordDecorator
  module AssignOperationCore
    class Operation
      attr_accessor :attr, :operator, :name

      def initialize(name, attr, value)
        @name = name
        @attr = attr
        @default_value = value
      end

      def perform(record: , value: nil)
        record.send("#{@attr}=", @default_value || value)
      end

      def match?(operation_name)
        operation_name == @name
      end
    end
  end
end