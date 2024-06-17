class RadiusRadpostauthCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    clean_records(Radius::Radpostauth, :username, :authdate, now)
  end
end
