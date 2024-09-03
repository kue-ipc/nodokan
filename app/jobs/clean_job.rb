# abstract job class
class CleanJob < ApplicationJob
  def clean_records(model, keys = nil, **)
    total = delete_expired_records(model, **)
    total += compress_past_records(model, keys, **) if keys.present?
    logger.info("Deleted #{model.name}: #{total}")
    total
  end

  def delete_expired_records(model, attr: :updated_at,
    date: Time.zone.now, retention_period: nil, **_opts)
    retention_period ||=
      Settings.config.retention_period[model.model_name.param_key]
    return 0 if retention_period.nil?

    expired_date = date - retention_period
    expired_reltaion = model.where({attr => (...expired_date)})
    delete_records(expired_reltaion)
  end

  def compress_past_records(model, keys, attr: :updated_at,
    date: Time.zone.now, nocompress_period: nil, **_opts)
    nocompress_period ||=
      Settings.config.nocompress_period[model.model_name.param_key]
    return 0 if nocompress_period.nil?

    past_date = date - nocompress_period
    model.distinct.pluck(*keys).sum do |data|
      condition = keys.zip(Array(data)).to_h
      last_record = model.where(condition).order(attr).last
      compress_date = [past_date, last_record.__send__(attr)].min
      compress_relation = model.where(condition)
        .where({attr => (...compress_date)})
      delete_records(compress_relation)
    end
  end
end
