json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @operating_systems
end
json.model do
  json.partial! "model", model: OperatingSystem
end
if @target
  json.data do
    json.array! @operating_systems, :id, @target, :description
  end
else
  json.entities do
    json.array! @operating_systems, partial: "operating_systems/operating_system", as: :operating_system
  end
end
