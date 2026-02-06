module PolicyHelper
  def assert_permit(user, record, action)
    msg = "User #{user.username} should be permitted to #{action} #{record}, but isn't permitted"
    assert permit(user, record, action), msg
  end

  def assert_not_permit(user, record, action)
    msg = "User #{user.username} should NOT be permitted to #{action} #{record}, but is permitted"
    assert_not permit(user, record, action), msg
  end

  private def permit(user, record, action)
    Pundit.policy(user, record).public_send("#{action}?")
  end

  def policy_scope(user, model)
    Pundit.policy_scope(user, model)
  end
end
