json.url request.url
json.pramas params
json.page do
  json.partial! 'page', entities: @device_types
end
json.model do
  json.partial! 'model', model: DeviceType
end
json.entities do
  json.array! @device_types, partial: 'device_types/device_type', as: :device_type
end
