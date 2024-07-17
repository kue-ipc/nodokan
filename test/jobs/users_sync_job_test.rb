require "test_helper"

class UsersSyncJobTest < ActiveJob::TestCase
  def user2entry(user)
    entry = Net::LDAP::Entry.new
    entry["mail"] = user.email
    entry["displayName"] = user.fullname
    entry
  end

  test "user sync" do
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list, users.reject(&:deleted).map(&:username))
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      perform_enqueued_jobs do
        UsersSyncJob.perform_later
      end
    end
    adapter.verify
  end

  test "user sync update" do
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list, users.reject(&:deleted).map(&:username))
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      alt_user = User.new(username: user.username, email: "dummy@example.jp",
        fullname: "dummy full")
      adapter.expect(:get_ldap_entry, user2entry(alt_user), [user.username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      perform_enqueued_jobs do
        UsersSyncJob.perform_later
      end
    end
    adapter.verify
    User.where(deleted: false).find_each do |user|
      assert_equal "dummy@example.jp", user.email
      assert_equal "dummy full", user.fullname
    end
  end

  test "user sync delete" do
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list, [])
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, false, [user.username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      perform_enqueued_jobs do
        UsersSyncJob.perform_later
      end
    end
    adapter.verify
    User.find_each do |user|
      assert_equal true, user.deleted
    end
  end

  test "user sync add users of admin group" do
    new_users = ["user1", "user2", "user3"]
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list,
      users.reject(&:deleted).map(&:username) + new_users)
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    new_users.each do |username|
      adapter.expect(:authorizable?, true, [username])
      user = User.new(username: username, email: "#{username}@exmaple.jp",
        fullname: username)
      adapter.expect(:get_ldap_entry, user2entry(user), [username])
      adapter.expect(:get_group_list, ["cn=admin,ou=groups,dc=example,dc=jp"],
        [username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      assert_difference("User.count", new_users.size) do
        perform_enqueued_jobs do
          UsersSyncJob.perform_later
        end
      end
    end
    adapter.verify
    new_users.each do |username|
      new_user = User.find_by(username: username)
      assert_nil new_user.auth_network
      assert_empty new_user.use_networks
      assert_nil new_user.limit
    end
  end

  test "user sync add users of staff group" do
    new_users = ["user1", "user2", "user3"]
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list,
      users.reject(&:deleted).map(&:username) + new_users)
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    new_users.each do |username|
      adapter.expect(:authorizable?, true, [username])
      user = User.new(username: username, email: "#{username}@exmaple.jp",
        fullname: username)
      adapter.expect(:get_ldap_entry, user2entry(user), [username])
      adapter.expect(:get_group_list, ["cn=staff,ou=groups,dc=example,dc=jp"],
        [username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      assert_difference("User.count", new_users.size) do
        perform_enqueued_jobs do
          UsersSyncJob.perform_later
        end
      end
    end
    adapter.verify
    new_users.each do |username|
      new_user = User.find_by(username: username)
      assert_equal 102, new_user.auth_network&.vlan
      assert_equal [101, 102], new_user.use_networks&.map(&:vlan)&.sort
      assert_nil new_user.limit
    end
  end

  test "user sync add users of user group" do
    new_users = ["user1", "user2", "user3"]
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list,
      users.reject(&:deleted).map(&:username) + new_users)
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    new_users.each do |username|
      adapter.expect(:authorizable?, true, [username])
      user = User.new(username: username, email: "#{username}@exmaple.jp",
        fullname: username)
      adapter.expect(:get_ldap_entry, user2entry(user), [username])
      adapter.expect(:get_group_list, ["cn=user,ou=groups,dc=example,dc=jp"],
        [username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      assert_difference("User.count", new_users.size) do
        perform_enqueued_jobs do
          UsersSyncJob.perform_later
        end
      end
    end
    adapter.verify
    new_users.each do |username|
      new_user = User.find_by(username: username)
      auth_vlan = new_user.auth_network&.vlan
      assert_kind_of Integer, auth_vlan
      assert_equal [auth_vlan], new_user.use_networks&.map(&:vlan)&.sort
      assert_equal 1, new_user.limit
    end
  end

  test "user sync skip users" do
    new_users = ["user1", "user2", "user3"]
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list,
      users.reject(&:deleted).map(&:username) + new_users)
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    new_users.each do |username|
      adapter.expect(:authorizable?, false, [username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      assert_no_difference("User.count") do
        perform_enqueued_jobs do
          UsersSyncJob.perform_later
        end
      end
    end
    adapter.verify
    new_users.each do |username|
      assert_nil User.find_by(username: username)
    end
  end

  test "user sync recover users" do
    new_users = ["deleted"]
    adapter = Minitest::Mock.new
    adapter.expect(:get_login_list,
      users.reject(&:deleted).map(&:username) + new_users)
    User.where(deleted: false).find_each do |user|
      adapter.expect(:authorizable?, true, [user.username])
      adapter.expect(:get_ldap_entry, user2entry(user), [user.username])
    end
    new_users.each do |username|
      adapter.expect(:authorizable?, true, [username])
      user = User.new(username: username, email: "dummy@example.jp",
        fullname: "dummy full")
      adapter.expect(:get_ldap_entry, user2entry(user), [username])
    end
    Devise::LDAP.stub_const :Adapter, adapter do
      assert_no_difference("User.count") do
        perform_enqueued_jobs do
          UsersSyncJob.perform_later
        end
      end
    end
    adapter.verify
    new_users.each do |username|
      user = User.find_by(username: username)
      assert_equal "dummy@example.jp", user.email
      assert_equal "dummy full", user.fullname
      assert_equal false, user.deleted
    end
  end
end
