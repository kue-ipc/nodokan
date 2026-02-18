class BulkCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.current)
    clean_records(Bulk, [:user_id], base:)
  end
end
