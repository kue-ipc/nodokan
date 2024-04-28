require "test_helper"

class UsersSyncJobTest < ActiveJob::TestCase
  setup do
    @adapter = Minitest::Mock.new
    @adapter.expect(:get_login_list, users.map(&:username))
    User.where(deleted: false).find_each do |user|
      unless user.deleted
        @adapter.expect(:authorizable?, true, [user.username])
        entry = Net::LDAP::Entry.new
        entry["mail"] = user.email
        entry["displayName"] = user.fullname
        @adapter.expect(:get_ldap_entry, entry, [user.username])
      end
    end
  end

  test "user sync" do
    Devise::LDAP.stub_const :Adapter, @adapter do
      perform_enqueued_jobs do
        UsersSyncJob.perform_later
      end
    end
    @adapter.verify
  end
end
