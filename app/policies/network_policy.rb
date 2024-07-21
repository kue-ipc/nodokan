class NetworkPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:users).where(users: user)
      end
    end
  end

  def show?
    user.admin? ||
      record.users.exists?(user.id) ||
      record.nodes.exists?(user_id: user.id)
  end
end
