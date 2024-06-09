class RadiusCleanJob < ApplicationJob
  queue_as :default

  def perform(*args)
    today = Time.today
    nocompress_date_range =
      Range.new(today - Settigs.config.nocompress_period, nil)
    limit_size = 1000
    total = 0

    if Settings.config.reteniton_period
      retention_date_range =
        Range.new(today - Settings.config.reteniton_period, nil)
      count = Radius::Radpostauth.where.not(authdate: retention_date_range).count
      ((count / limit_size) + 1).times do
        total += Radius::Radpostauth
          .where.not(authdate: retention_date_range)
          .limit(limit_size).delete_all
      end
    end

    Radius::Radpostauth.group(:username).count.filter { |_k, v| v > 1 }
      .each do |username, count|
      ((count / limit_size) + 1).times do
        total += Radius::Radpostauth
          .where(username: username)
          .where.not(id: Radius::Radpostauth.where(username: username)
            .order(:authdate).last.id)
          .where.not(authdate: nocompress_date_range)
          .limit(limit_size).delete_all
      end
    end
    logger.info("Deleted: #{total}")
  end
end
