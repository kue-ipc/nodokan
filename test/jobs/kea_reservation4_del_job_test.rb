require "test_helper"

class KeaReservation4DelJobTest < ActiveJob::TestCase
  setup do
    @nic = nics(:note)
  end

  test "del reservation" do
    perform_enqueued_jobs do
      KeaReservation4AddJob.perform_later(@nic.network.id,
        @nic.mac_address_data, @nic.ipv4)
    end
    assert_difference("Kea::Host.count", -1) do
      perform_enqueued_jobs do
        KeaReservation4DelJob.perform_later(@nic.network.id,
          @nic.mac_address_data)
      end
    end
  end

  test "del reservation not exist" do
    assert_no_difference("Kea::Host.count") do
      perform_enqueued_jobs do
        KeaReservation4DelJob.perform_later(@nic.network.id,
          @nic.mac_address_data)
      end
    end
  end
end
