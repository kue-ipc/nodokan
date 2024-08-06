json.extract! bulk, :id, :user_id, :target, :status,
  :number, :success, :failure, :created_at, :updated_at
json.input url_for(bulk.input) if bulk.input.attached?
json.output url_for(bulk.output) if bulk.output.attached?
json.url bulk_url(bulk, format: :json)
