class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  rescue_from(StandardError) do |exception|
    AdminMailer.with(job: self.class.name, job_id: job_id, time: Time.current, exception: exception.message)
      .job_failure.deliver_later
    raise exception
  end

  # Radius関係のレコードを更新するとき専用
  # NOTE: テーブルがVIEWであるため、作成時に `id: nil` を設定する必要がある
  # idを設定する必要がる
  def update_radius_user(model_class, username:, **params)
    primary_key = model_class.primary_key&.intern || :id
    record = model_class.find_by_username(username)
    if record
      # 重複するデータがある場合は事前に削除しておく。
      model_class.where(username: username).where.not(primary_key => record.__send__(primary_key)).destroy_all
      record.update!(**params)
    else
      model_class.create!(primary_key => nil, username: username, **params)
    end
  end
end
