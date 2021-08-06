json.name klass.name
json.human_name klass.model_name.human
json.attributes do
  json.array! klass.attribute_names do |name|
    json.name name
    json.human_name klass.human_attribute_name(name)
    json.type klass.type_for_attribute(name).type
  end
end
