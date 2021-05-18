class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
