require "test_helper"

class KeaReservation6AddJobTest < ActiveJob::TestCase
  setup do
    @nic = nics(:note)
  end

  test "add reservation" do
    assert_difference("Kea::Host.count") do
      assert_difference("Kea::Ipv6Reservation.count") do
        perform_enqueued_jobs do
          KeaReservation6AddJob.perform_later(@nic.network.id,
            @nic.node.duid_data, @nic.ipv6)
        end
      end
    end
    host = Kea::Host.last
    assert_equal @nic.network.id, host.dhcp6_subnet_id
    assert_equal @nic.node.duid_data, host.dhcp_identifier
    assert_equal @nic.ipv6.to_s, host.ipv6_reservation.address
    assert_equal Kea::HostIdentifierType.duid, host.host_identifier_type
  end

  test "add reservation update" do
    perform_enqueued_jobs do
      KeaReservation6AddJob.perform_later(@nic.network.id,
        @nic.node.duid_data, @nic.ipv6)
    end
    assert_no_difference("Kea::Host.count") do
      assert_no_difference("Kea::Ipv6Reservation.count") do
        perform_enqueued_jobs do
          KeaReservation6AddJob.perform_later(@nic.network.id,
            @nic.node.duid_data, @nic.ipv6.succ)
        end
      end
    end
    host = Kea::Host.last
    assert_equal @nic.network.id, host.dhcp6_subnet_id
    assert_equal @nic.node.duid_data, host.dhcp_identifier
    assert_equal @nic.ipv6.succ.to_s, host.ipv6_reservation.address
    assert_equal Kea::HostIdentifierType.duid, host.host_identifier_type
  end
end
