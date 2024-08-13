class RadiusRadpostauthCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.zone.now)
    clean_records(Radius::Radpostauth, [:username],
      attr: :authdate, base: base)
  end
end
