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

  # cannot destroy user by manual operation, but can be destroyed by ldap synchronization or other background process.
  def destroy?
    false
  end
end
