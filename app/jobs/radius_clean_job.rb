class RadiusCleanJob < ApplicationJob
  queue_as :clean

  LIMIT_SIZE = 1000

  def perform(now = Time.zone.now, limit_size: LIMIT_SIZE)
    clean_radacct(now, limit_size: limit_size)
    clean_radpostauth(now, limit_size: limit_size)
  end


  def clean_radacct(now = Time.zone.now, limit_size: LIMIT_SIZE)
    total = 0

    if Settings.config.reteniton_period
      total +=
        delete_expried_radacct(now - Settings.config.reteniton_period,
          limit_size: limit_size)
    end

    Radius::Radacct.pluck(:username).each do |username|
      total +=
        compress_past_radacct(username,
          now - (Settigs.config.nocompress_period || 0),
          limit_size: limit_size)
    end
    logger.info("Deleted radacct: #{total}")
  end

  def delete_expried_radacct(expired_date, limit_size: LIMIT_SIZE)
    return 0 if expired_date.nil?

    total = 0
    loop do
      count = Radius::Radacct
        .where.not(acctupdatetime: Range.new(expired_date, nil))
        .limit(limit_size)
        .delete_all
      total += count
      break if count < limit_size
    end
    total
  end

  def compress_past_radacct(username, compress_date, limit_size: LIMIT_SIZE)
    compress_date = Time.zone.return 0 if compress_date.nil?

    last_record =
      Radius::Radacct.where(username: username).order(:acctupdatetime).last
    return 0 if last_record.nil?

    total = 0
    loop do
      count = Radius::Radacct
        .where(username: username)
        .where.not(id: last_record.id)
        .where.not(acctupdatetime: Range.new(compress_date, nil))
        .limit(limit_size)
        .delete_all
      total += count
      break if count < limit_size
    end
    total
  end

  def clean_radpostauth(now = Time.zone.now, limit_size: LIMIT_SIZE)
    total = 0

    if Settings.config.reteniton_period
      total +=
        delete_expried_radpostauth(now - Settings.config.reteniton_period,
          limit_size: limit_size)
    end

    Radius::Radpostauth.pluck(:username).each do |username|
      total +=
        compress_past_radpostauth(username,
          now - Settigs.config.nocompress_period,
          limit_size: limit_size)
    end
    logger.info("Deleted radpostauth: #{total}")
  end

  def delete_expried_radpostauth(expired_date, limit_size: LIMIT_SIZE)
    return 0 if expired_date.nil?

    total = 0
    loop do
      count = Radius::Radpostauth
        .where.not(authdate: Range.new(expired_date, nil))
        .limit(limit_size)
        .delete_all
      total += count
      break if count < limit_size
    end
    total
  end

  def compress_past_radpostauth(username, compress_date, limit_size: LIMIT_SIZE)
    return 0 if compress_date.nil?

    last_record =
      Radius::Radpostauth.where(username: username).order(:authdate).last
    return 0 if last_record.nil?

    total = 0
    loop do
      count = Radius::Radpostauth
        .where(username: username)
        .where.not(id: last_record.id)
        .where.not(authdate: Range.new(compress_date, nil))
        .limit(limit_size)
        .delete_all
      total += count
      break if count < limit_size
    end
    total
  end
end
