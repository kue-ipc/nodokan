class Ipv4ArpCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    total = 0

    if Settings.config.reteniton_period
      expired_date = now - Settings.config.reteniton_period
      expired_reltaion = Ipv4Arp.where(end_at: (...expired_date))
      total += delete_records(expired_reltaion)
    end

    Ipv4Arp.pluck(:ipv4_data).each do |ipv4_data|
      last_record = Ipv4Arp.where(ipv4_data: ipv4_data).order(:end_at).last
      next if last_record.nil?

      compress_relation = Ipv4Arp.where(ipv4_data: ipv4_data)
        .where.not(id: last_record.id)
      if Settings.config.nocompress_period
        compress_date = now - Settings.config.nocompress_period
        compress_relation = compress_relation.where(end_at: (...compress_date))
      end
      total += delete_records(compress_relation)
    end

    logger.info("Deleted ipv4_arp: #{total}")
  end
end
