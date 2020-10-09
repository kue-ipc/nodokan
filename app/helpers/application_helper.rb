module ApplicationHelper
  def t_enums(model_class, attr_name)
    class_name = model_class.name.underscore.to_sym
    model_class.__send__(attr_name).keys.index_by do |key|
      t(key, scope: [:activerecord, :enums, attr_name])
    end
  end
end
