class NetworkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if @user.admin?
        scope.all
      else
        scope.where(users: @user)
      end
    end
  end

  def index?
    true
  end
end
