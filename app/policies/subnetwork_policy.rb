class SubnetworkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.include(:subnetwork_user)
          .where(subnetwork_user: {user: user})
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
