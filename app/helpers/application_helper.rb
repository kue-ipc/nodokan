module ApplicationHelper
  def t_enums(model_class, attr_name)
    class_name = model_class.name.underscore.to_sym
    model_class.__send__(attr_name).keys.map do |key|
      [t(key, scope: [:activerecord, :enums, class_name, attr_name]), key]
    end.to_h
  end
end
