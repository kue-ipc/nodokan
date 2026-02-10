json.name model.name
json.human_name model.model_name.human
json.param_key model.model_name.param_key
json.attributes do
  json.array! model.attribute_names do |name|
    json.name name
    json.human_name model.human_attribute_name(name)
    json.type model.type_for_attribute(name).type
    json.readonly %w[id created_at updated_at].include?(name) || name.end_with?("_count")
  end
end
