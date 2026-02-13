class RadiusRadpostauthCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.current)
    clean_records(Radius::Radpostauth, [:username], attr: :authdate, base:)
  end
end
