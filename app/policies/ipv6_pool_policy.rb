class Ipv6PoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(network: :users).where(network: {users: user})
      end
    end
  end
end
