class RadiusRadacctCleanJob < CleanJob
  queue_as :clean

  def perform(date: Time.zone.now)
    clean_records(Radius::Radacct, [:username], date_attr: :acctupdatetime,
      date: date)
  end
end
