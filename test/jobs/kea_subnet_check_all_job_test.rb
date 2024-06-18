require "test_helper"

class KeaSubnetCheckAllJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: true)
      Kea::Dhcp4Subnet.destroy_all
    end
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit(cascade_transaction: true)
      Kea::Dhcp6Subnet.destroy_all
    end
  end

  test "check all" do
    perform_enqueued_jobs do
      KeaSubnetCheckAllJob.perform_later
    end
  end
end
