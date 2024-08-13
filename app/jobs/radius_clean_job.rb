class RadiusCleanJob < ApplicationJob
  queue_as :clean

  def perform(**opts)
    RadiusRadacctCleanJob.perform_later(**opts)
    RadiusRadpostauthCleanJob.perform_later(**opts)
  end
end
