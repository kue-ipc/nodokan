class RadiusCleanJob < ApplicationJob
  queue_as :clean

  LIMIT_SIZE = 1000

  def perform(now = Time.zone.now)
    RadiusRadacctCleanJob.perform_later(now)
    RadiusRadpostauthCleanJob.perform_later(now)
  end
end
