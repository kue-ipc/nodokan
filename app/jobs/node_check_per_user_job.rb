class NodeCheckPerUserJob < ApplicationJob
  queue_as :check

  def perform(user)
    user.nodes.find_each do |node|
      # TODO: ここに処理
    end
  end
end
