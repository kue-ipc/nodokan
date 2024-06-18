# abstract job class
class CleanJob < ApplicationJob
  LIMIT_SIZE = 1000

  def delete_records(relation, size: LIMIT_SIZE, once: false)
    if !size.positive?
      relation.delete_all
    elsif once
      relation.limit(size).delete_all
    else
      total = 0
      loop do
        count = relation.limit(size).delete_all
        total += count
        break if count < size

        logger.debug("Repeat deletion")
      end
      total
    end
  end

  def clean_records(model, key_attr, date_attr, now = Time.zone.now)
    total = delete_expired_records(model, date_attr, now) +
      compress_past_records(model, key_attr, date_attr, now)
    logger.info("Deleted #{model.name}: #{total}")
  end

  def delete_expired_records(model, date_attr, now = Time.zone.now)
    return 0 if Settings.config.reteniton_period.nil?

    expired_date = now - Settings.config.reteniton_period
    expired_reltaion = model.where({date_attr => (...expired_date)})
    delete_records(expired_reltaion)
  end

  def compress_past_records(model, key_attr, date_attr, now = Time.zone.now)
    model.pluck(key_attr).sum do |data|
      last_record = model.where({key_attr => data}).order(date_attr).last
      next 0 if last_record.nil?

      compress_relation = model.where({key_attr => data})
        .where.not(id: last_record.id)
      if Settings.config.nocompress_period
        compress_date = now - Settings.config.nocompress_period
        compress_relation =
          compress_relation.where({date_attr => (...compress_date)})
      end
      delete_records(compress_relation)
    end
  end
end
