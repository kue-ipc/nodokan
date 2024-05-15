class Ipv4ArpCleanJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
