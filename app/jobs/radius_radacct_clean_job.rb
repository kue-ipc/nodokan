class RadiusRadacctCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    clean_records(Radius::Radacct, :username, :acctupdatetime, now)
  end
end
