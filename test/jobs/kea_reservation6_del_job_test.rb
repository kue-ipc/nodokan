require "test_helper"

class KeaReservation6DelJobTest < ActiveJob::TestCase
  setup do
    @nic = nics(:note)
  end

  test "del reservation" do
    @nic = nics(:note)
    perform_enqueued_jobs do
      KeaReservation6AddJob.perform_later(@nic.network.id,
        @nic.node.duid_data, @nic.ipv6)
    end
    assert_difference("Kea::Host.count", -1) do
      assert_difference("Kea::Ipv6Reservation.count", -1) do
        perform_enqueued_jobs do
          KeaReservation6DelJob.perform_later(@nic.network.id,
            @nic.node.duid_data)
        end
      end
    end
  end

  test "del reservation not exist" do
    @nic = nics(:note)
    assert_no_difference("Kea::Host.count") do
      assert_no_difference("Kea::Ipv6Reservation.count") do
        perform_enqueued_jobs do
          KeaReservation6DelJob.perform_later(@nic.network.id,
            @nic.node.duid_data)
        end
      end
    end
  end
end
