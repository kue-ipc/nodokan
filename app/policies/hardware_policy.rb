class HardwarePolicy < ApplicationPolicy
  class Scope < Scope
  end

  def manage?
    update?
  end
end
