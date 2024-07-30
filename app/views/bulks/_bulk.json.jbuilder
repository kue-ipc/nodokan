json.extract! bulk, :id, :user_id, :model, :status, :number, :success, :failure,
  :created_at, :updated_at
json.file url_for(bulk.file) if bulk.file.attached?
json.result url_for(bulk.result) if bulk.result.attached?
json.url bulk_url(bulk, format: :json)
