# abstract job class
class CleanJob < ApplicationJob
  def clean_records(model, key_attrs, **opts)
    total =
      delete_expired_records(model, **opts) +
      compress_past_records(model, key_attrs, **opts)
    logger.info("Deleted #{model.name}: #{total}")
    total
  end

  def delete_expired_records(model, date_attr: :updated_at, date: Time.zone.now)
    retention_period =
      Settings.config.retention_period[model.model_name.param_key]
    return 0 if retention_period.nil?

    expired_date = date - retention_period
    expired_reltaion = model.where({date_attr => (...expired_date)})
    delete_records(expired_reltaion)
  end

  def compress_past_records(model, key_attrs, date_attr: :updated_at,
    date: Time.zone.now)
    nocompress_period =
      Settings.config.nocompress_period[model.model_name.param_key]
    return 0 if nocompress_period.nil?

    past_date = date - nocompress_period
    model.distinct.pluck(*key_attrs).sum do |data|
      condition = key_attrs.zip(Array(data)).to_h
      last_record = model.where(condition).order(date_attr).last
      compress_date = [past_date, last_record.__send__(date_attr)].min
      compress_relation = model.where(condition)
        .where({date_attr => (...compress_date)})
      delete_records(compress_relation)
    end
  end
end
