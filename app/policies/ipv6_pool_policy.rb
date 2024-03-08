class Ipv6PoolPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:users, :networks).where(network: {users: user})
      end
    end
  end
end
