class RadiusRadpostauthCleanJob < CleanJob
  queue_as :clean

  def perform(date: Time.zone.now)
    clean_records(Radius::Radpostauth, [:username], date_attr: :authdate,
      date: date)
  end
end
