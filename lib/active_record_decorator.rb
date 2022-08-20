
module ActiveRecordDecorator
  extend ActiveSupport::Concern

  included do
    class_attribute :relation_callback_chain
    self.relation_callback_chain = Concurrent::Array.new

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
end