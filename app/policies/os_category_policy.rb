class OsCategoryPolicy < ApplicationPolicy
  class Scope < Scope
  end

  def manage?
    user.admin?
  end
end
