class SecuritySoftwarePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def manage?
    user.admin?
  end
end
