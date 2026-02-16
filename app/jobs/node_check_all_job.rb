class NodeCheckAllJob < ApplicationJob
  queue_as :check

  def perform(*args)
    # Do something later
  end
end
