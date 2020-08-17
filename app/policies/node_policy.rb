class NodePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def copy?
    show? && new?
  end
end
