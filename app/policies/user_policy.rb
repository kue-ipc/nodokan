class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end

  def show?
    user.admin? || record == user
  end

  # No one can create or destroy users. All users are created and destroyed by LDAP synchronization.

  def create?
    false
  end

  def destroy?
    false
  end
end
