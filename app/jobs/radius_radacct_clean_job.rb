class RadiusRadacctCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    total = 0

    if Settings.config.reteniton_period
      expired_date = now - Settings.config.reteniton_period
      expired_reltaion =
        Radius::Radacct.where(acctupdatetime: (...expired_date))
      total += delete_records(expired_reltaion)
    end

    Radius::Radacct.pluck(:username).each do |username|
      last_record =
        Radius::Radacct.where(username: username).order(:acctupdatetime).last
      next if last_record.nil?

      compress_relation = Radius::Radacct.where(username: username)
        .where.not(id: last_record.id)
      if Settigs.config.nocompress_period
        compress_date = now - Settigs.config.nocompress_period
        compress_relation =
          compress_relation.where(acctupdatetime: (...compress_date))
      end
      total += delete_records(compress_relation)
    end

    logger.info("Deleted radius radacct: #{total}")
  end
end
