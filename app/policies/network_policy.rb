class NetworkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    user.admin? ||
      record.users.exists?(user.id) ||
      record.nodes.exists?(user_id: user.id)
  end
end
