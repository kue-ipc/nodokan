class RadiusRadpostauthCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    total = 0

    if Settings.config.reteniton_period
      expired_date = now - Settings.config.reteniton_period
      expired_reltaion = Radius::Radpostauth.where(authdate: (...expired_date))
      total += delete_records(expired_reltaion)
    end

    Radius::Radpostauth.pluck(:username).each do |username|
      last_record = Radius::Radpostauth.where(username: username).order(:authdate).last
      next if last_record.nil?

      compress_relation = Radius::Radpostauth.where(username: username)
        .where.not(id: last_record.id)
      if Settings.config.nocompress_period
        compress_date = now - Settings.config.nocompress_period
        compress_relation = compress_relation.where(authdate: (...compress_date))
      end
      total += delete_records(compress_relation)
    end

    logger.info("Deleted radius radpostauth: #{total}")
  end
end
