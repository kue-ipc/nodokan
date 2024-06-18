require "test_helper"

class KeaSubnet4DelJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: true)
      Kea::Dhcp4Subnet.destroy_all
    end

    @network = networks(:client)
  end

  test "del subnet" do
    perform_enqueued_jobs do
      KeaSubnet4AddJob.perform_later(@network.id, @network.ipv4_network, {}, [])
    end
    assert_difference("Kea::Dhcp4Subnet.count", -1) do
      perform_enqueued_jobs do
        KeaSubnet4DelJob.perform_later(@network.id)
      end
    end
  end

  test "del subnet not exist" do
    assert_no_difference("Kea::Dhcp4Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet4DelJob.perform_later(@network.id)
      end
    end
  end
end
