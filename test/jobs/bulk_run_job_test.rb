require "test_helper"

class BulkRunJobTest < ActiveJob::TestCase
  test "run import" do
    bulk = bulks(:import)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)

    # warn "--------------"
    # warn bulk.input.content_type
    # warn bulk.input.blob.inspect
    # # bulk.input.open do |file|
    # #   file.each_line do |line|
    # #     warn line
    # #   end
    # # end

    bulk.output.open do |file|
      file.each_line do |line|
        warn line
      end
    end
    assert_equal "succeeded", bulk.status
  end
end
