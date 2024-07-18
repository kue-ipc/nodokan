class RadiusCleanJob < ApplicationJob
  queue_as :clean

  LIMIT_SIZE = 1000

  def perform(**opts)
    RadiusRadacctCleanJob.perform_later(**opts)
    RadiusRadpostauthCleanJob.perform_later(**opts)
  end
end
