require "test_helper"

class KeaSubnet6DelJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit
      Kea::Dhcp6Subnet.destroy_all
    end

    @network = networks(:client)
  end

  test "del subnet" do
    perform_enqueued_jobs do
      KeaSubnet6AddJob.perform_later(@network.id, @network.ipv6_network, {}, [])
    end
    assert_difference("Kea::Dhcp6Subnet.count", -1) do
      perform_enqueued_jobs do
        KeaSubnet6DelJob.perform_later(@network.id)
      end
    end
  end

  test "del subnet not exist" do
    assert_no_difference("Kea::Dhcp6Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet6DelJob.perform_later(@network.id)
      end
    end
  end
end
