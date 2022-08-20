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