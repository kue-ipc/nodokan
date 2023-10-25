class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # TODO: Do something later
    # NOTE:
    #   Kea::Ipv6Reservation は VIEW 経由にになるため、作成時に  {reservation_id: nil} を追加すること
  end
end
