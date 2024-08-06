class HardwarePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def manage?
    update?
  end
end
