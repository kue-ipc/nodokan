class RadiusRadacctCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.zone.now)
    clean_records(Radius::Radacct, [:username],
      attr: :acctupdatetime, base:)
  end
end
