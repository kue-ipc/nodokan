class RadiusRadacctCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.current)
    clean_records(Radius::Radacct, [:username], attr: :acctupdatetime, base:)
  end
end
