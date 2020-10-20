class NodePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if @user.admin?
        scope.all
      else
        scope.where(user: @user)
      end
    end
  end

  def index?
    true
  end

  def show?
    @user.admin? || @record.user == @user
  end

  def create?
    @user.admin? || @record.user == @user
  end

  def update?
    @user.admin? || @record.user == @user
  end

  def destroy?
    @user.admin? || @record.user == @user
  end

  def copy?
    show? && new?
  end
end
