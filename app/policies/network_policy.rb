class NetworkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.includes(:users).where(users: user.id)
      end
    end
  end

  def index?
    true
  end

  def show?
    user.admin? ||
      record.users.include?(user)
  end
end
