class BulkCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.zone.now)
    clean_records(Bulk, [:user_id], base:)
  end
end
