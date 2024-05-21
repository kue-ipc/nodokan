require "test_helper"

class KeaReservation4AddJobTest < ActiveJob::TestCase
  setup do
    @nic = nics(:note)
  end

  test "add reservation" do
    assert_difference("Kea::Host.count") do
      perform_enqueued_jobs do
        KeaReservation4AddJob.perform_later(@nic.network_id,
          @nic.mac_address_data, @nic.ipv4)
      end
    end
    host = Kea::Host.last
    assert_equal @nic.network_id, host.dhcp4_subnet_id
    assert_equal @nic.mac_address_data, host.dhcp_identifier
    assert_equal @nic.ipv4.to_i, host.ipv4_address
    assert_equal Kea::HostIdentifierType.hw_address, host.host_identifier_type
  end

  test "add reservation update" do
    perform_enqueued_jobs do
      KeaReservation4AddJob.perform_later(@nic.network_id,
        @nic.mac_address_data, @nic.ipv4)
    end
    assert_no_difference("Kea::Host.count") do
      perform_enqueued_jobs do
        KeaReservation4AddJob.perform_later(@nic.network_id,
          @nic.mac_address_data, @nic.ipv4.succ)
      end
    end
    host = Kea::Host.last
    assert_equal @nic.network_id, host.dhcp4_subnet_id
    assert_equal @nic.mac_address_data, host.dhcp_identifier
    assert_equal @nic.ipv4.succ.to_i, host.ipv4_address
    assert_equal Kea::HostIdentifierType.hw_address, host.host_identifier_type
  end
end
