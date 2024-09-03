class RadiusCleanJob < ApplicationJob
  queue_as :clean

  def perform(**)
    RadiusRadacctCleanJob.perform_later(**)
    RadiusRadpostauthCleanJob.perform_later(**)
  end
end
