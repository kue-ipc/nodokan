class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Radius関係のレコードを更新するとき専用
  # NOTE: テーブルがVIEWであるため、作成時に `id: nil` を設定する必要がある
  # idを設定する必要がる
  def update_radius_user(model_class, username:, **params)
    primary_key = model_class.primary_key&.intern || :id
    record = model_class.find_by_username(username)
    if record
      model_class.where(username: username).where.not(primary_key => radcheck.__send__(id)).destroy_all
      record.update!(**params) if record.attributes.transform_keys(&:intern).slice(*params.keys) == params
    else
      model_class.create!(primary_key => nil, username: username, **params)
    end
  end
end
