class SubnetworkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.all
        # scope.where(users: {id: current_user.id})
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end
end
