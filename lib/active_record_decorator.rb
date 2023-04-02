
require 'active_record_decorator/assign_operation'
require 'active_record_decorator/assign_operation_core/operation'
require 'active_record_decorator/condition_evaluator'
require 'active_record_decorator/condition_alias_manager'
require 'active_record_decorator/condition_evaluator_core/condition'
require 'active_record_decorator/condition_evaluator_core/operators'
require 'active_record_decorator/condition_evaluator_core/value_object'

module ActiveRecordDecorator
  extend ActiveSupport::Concern

  class Callback

    attr_reader :relation_name, :method_name, :relation_class

    def initialize(relation_type, relation_name, relation_class, method_name)
      @relation_type = relation_type
      @relation_name = relation_name
      @method_name   = method_name
      @relation_class = relation_class
    end

    def build(relation_name, method_name)
      new(relation_name, method_name)
    end

    def relation_class_match?(rl_class)
      rl_class == @relation_class
    end

  end

  included do
    class_attribute :relation_callback_chain, :condition_aliases, :assign_operation_aliases
    self.relation_callback_chain = Concurrent::Array.new
    self.condition_aliases = Concurrent::Array.new
    self.assign_operation_aliases = Concurrent::Array.new

    # Return self if false else self with passed scoped attached
    # @param[condition] - deciding condition true/false to attach scope
    # @param[scope] - name of the scope
    # @param[scope_args] - Array of args
    scope :conditional_scope, lambda { |condition, scope, scope_args = []|
      if condition
        return self.public_send(scope) if scope_args.blank?

        return self.public_send(scope, *scope_args)
      end
      self
    }

    # Return self if @param[condition] false
    #   => else return self with passed includes attached
    # @param[condition] - deciding condition true/false to attach includes
    # @param[scope_args] - Array of args
    scope :conditional_includes, lambda { |condition, association|
      return self.includes(association) if condition
      self
    }

    after_update :run_callbacks_registered
  end

  module ClassMethods
    def on_has_one_update(relation_name, method, params = {})
      register_relation_callback(:has_one, relation_name, method, params)
    end

    def on_has_many_update(relation_name, method, params = {})
      register_relation_callback(:has_many, relation_name, method, params)
    end

    def register_relation_callback(relation_type, relation_name, method, params = {})
      return if self.relation_callback_chain.detect { |rl| rl.relation_name == relation_name }
      rl_reflects = self.reflect_on_all_associations(relation_type)
      rl_reflect = rl_reflects.find { |rl| rl.name == relation_name }
      self.relation_callback_chain << Callback.new(relation_type, relation_name, rl_reflect.klass, method)
    end

    def has_relation_callback_registered?(rl_class)
      status = false
      self.relation_callback_chain.each do |cb|
        if cb.relation_class_match?(rl_class)
          status = true
          break
        end
      end
      return status
    end

    def condition_alias(condition_name, *attributes)

      defaults = attributes.extract_options!.dup
      condition_name = condition_name
      operator = defaults[:operator]
      attr = defaults[:attr]
      value = defaults[:value]
      return if self.condition_aliases.detect { |rl| rl.name == condition_name }
      self.condition_aliases << ConditionEvaluatorCore::Condition.new(condition_name, attr, operator, value)
    end

    def all_condition_aliases
      self.condition_aliases
    end

    def assign_operation(name, *attributes)
      defaults = attributes.extract_options!.dup

      condition_name = name

      if self.instance_methods(false).include?(condition_name.to_sym)
        raise "already method defined"
      end


      attr = defaults[:attr]
      value = defaults[:value]
      return if self.assign_operation_aliases.detect { |rl| rl.name == condition_name }
      self.assign_operation_aliases << AssignOperationCore::Operation.new(condition_name, attr, value)
      delegate name.to_sym, to: :assign_operation_proxy
    end

    def all_assign_operation_aliases
      self.assign_operation_aliases
    end

  end

  def run_callbacks_registered()
    relations = self.class.reflect_on_all_associations(:belongs_to)
    relations.each do |rl|
      rl_class = rl.klass
      if rl_class.respond_to?(:has_relation_callback_registered?) && rl_class.has_relation_callback_registered?(self.class)
        run_callback_for_relation_class(rl_class, self)
      end
    end
  end

  def run_callback_for_relation_class(rl_class, model)
    rl_class.relation_callback_chain.each do |cb|
      if cb.relation_class_match?(self.class)
        rl = self.class.reflect_on_all_associations(:belongs_to).find { |rl_reflect| rl_reflect.klass == rl_class }
        model.send(rl.name).send(cb.method_name) if rl
      end
    end
  end

  def condition_match?(condition_to_evaluate)
    ActiveRecordDecorator::ConditionEvaluator.new(record: self, condition_to_evaluate: condition_to_evaluate).evaluate
  end

  def assign_operation_proxy
    @assign_operation_proxy ||=  ActiveRecordDecorator::AssignOperation.new(record: self)
  end

  def in_batches_by_column(column:, batch_size: 1000, start: 1)
    relation = self
    offset_id = 0
    start = 1 unless start.positive?
    relation = relation.distinct(column.to_sym).order(column.to_sym).limit(batch_size)
    relation = relation.where("#{column} >= #{start}") if start > 1
    relation.skip_query_cache!
    batch_relation = relation

    loop do
      data = batch_relation.pluck(column)
      break if data.empty?

      yield data
      offset_id = data.last
      batch_relation = relation.where("#{column} > #{offset_id}")
    end
  end

end