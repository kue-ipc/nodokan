class Ipv6NeighborCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    total = 0

    if Settings.config.reteniton_period
      expired_date = now - Settings.config.reteniton_period
      expired_reltaion = Ipv6Neighbor.where(end_at: (...expired_date))
      total += delete_records(expired_reltaion)
    end

    Ipv6Neighbor.pluck(:ipv6_data).each do |ipv6_data|
      last_record = Ipv6Neighbor.where(ipv6_data: ipv6_data).order(:end_at).last
      next if last_record.nil?

      compress_relation = Ipv6Neighbor.where(ipv6_data: ipv6_data)
        .where.not(id: last_record.id)
      if Settings.config.nocompress_period
        compress_date = now - Settings.config.nocompress_period
        compress_relation = compress_relation.where(end_at: (...compress_date))
      end
      total += delete_records(compress_relation)
    end

    logger.info("Deleted ipv6_neighbor: #{total}")
  end
end
