require "test_helper"

class KeaSubnet4DelJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: true)
      Kea::Dhcp4Subnet.destroy_all
    end

    @network = networks(:client)
    @nic = nics(:note)
  end

  test "del subnet" do
    KeaSubnet4AddJob.perform_now(@network.id, @network.ipv4_network_prefix, {}, [])
    KeaReservation4AddJob.perform_now(@network.id, @nic.mac_address, @nic.ipv4)
    assert_difference("Kea::Host.count", -1) do
      assert_difference("Kea::Dhcp4Subnet.count", -1) do
        perform_enqueued_jobs do
          KeaSubnet4DelJob.perform_later(@network.id)
        end
      end
    end
  end

  test "del subnet not exist" do
    assert_no_difference("Kea::Host.count") do
      assert_no_difference("Kea::Dhcp4Subnet.count") do
        perform_enqueued_jobs do
          KeaSubnet4DelJob.perform_later(@network.id)
        end
      end
    end
  end
end
