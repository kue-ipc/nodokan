json.extract! bulk, :id, :user_id, :model, :status, :started_at, :stopped_at,
  :file, :result, :created_at, :updated_at
json.url bulk_url(bulk, format: :json)
json.file url_for(bulk.file)
json.result url_for(bulk.result)
