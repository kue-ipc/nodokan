# see
# https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/configuration-in-db-design

class KeaSubnet6AddJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
