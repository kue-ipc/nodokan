class NicPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  def show?
    user.admin? || record.node&.user == user
  end

  def create?
    user.admin? || (!user.guest? && record.node&.user == user)
  end

  def update?
    user.admin? || record.node&.user == user
  end

  def destroy?
    user.admin? || (!user.guest? && record.node&.user == user)
  end
end
