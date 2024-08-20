require "test_helper"

class BulkRunJobTest < ActiveJob::TestCase
  test "run import" do
    bulk = bulks(:import)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    node = Node.find(output[0]["id"])
    assert_equal "パソコン", node.name
    assert_equal "LAN", node.nics.first.name
  end
end
