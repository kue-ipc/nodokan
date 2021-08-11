json.extract! hardware, :id, :device_type_id, :maker, :product_name,
  :model_number, :confirmed, :locked, :nodes_count, :created_at, :updated_at
json.url hardware_url(hardware)
