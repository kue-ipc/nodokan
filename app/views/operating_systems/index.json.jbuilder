json.ignore_nil!
json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @operating_systems
end
case @target
in nil
  json.model do
    json.partial! "model", model: OperatingSystem
  end
  json.entities do
    json.array! @operating_systems, partial: "operating_systems/operating_system", as: :operating_system
  end
in :os_category_id
  json.data do
    json.array! @operating_systems do |operating_system|
      json.os_category_id operating_system.os_category_id
      json.name operating_system.os_category.name
      json.description operating_system.os_category.description
      json.locked operating_system.os_category.locked if operating_system.os_category.locked
      json.required true
    end
  end
in :name
  json.data do
    json.array! @operating_systems do |operating_system|
      json.name operating_system.name
      json.description operating_system.description
    end
  end
end
