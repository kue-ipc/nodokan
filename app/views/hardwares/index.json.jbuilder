json.url request.url
json.params params
json.page do
  json.partial! "page", entities: @hardwares
end
case @target
in nil
  json.model do
    json.partial! "model", model: Hardware
  end
  json.entities do
    json.array! @hardwares, partial: "hardwares/hardware", as: :hardware
  end
in :device_type_id
  json.ignore_nil!
  json.data do
    json.array! @hardwares do |hardware|
      json.device_type_id hardware.device_type_id
      json.name hardware.device_type.name
      json.description hardware.device_type.description
      json.locked hardware.device_type.locked if hardware.device_type.locked
    end
  end
in :maker | :product_name | :model_number
  json.ignore_nil!
  json.data do
    json.array! @hardwares, @target
  end
end
