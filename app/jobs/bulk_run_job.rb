require "stringio"

class BulkRunJob < ApplicationJob
  class DuplicateRunError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  discard_on DuplicateRunError, BulkRunError

  def perform(bulk)
    if bulk.file.content_type != "text/csv"
      raise BulkRunError, "Unknown content type: #{bulk.file.content_type}"
    end

    result_io = StringIO.new

    # TODO: 細かい実装
    start(bulk)
    run(bulk)
    stop(bulk)
  rescue DuplicateRunError
    raise
  rescue StandardError => e
    bulk.update(status: :error)
    bulk.result.attach(io: result_io, filename: "result.csv",
      content_type: bulk.file.content_type, identify: false)
    raise BulkRunError, e.message
  end

  def start(bulk)
    bulk.with_lock do
      unless bulk.waiting?
        raise DuplicateRunError, "Bulk status is not waiting: Bulk##{bulk.id}"
      end

      bulk.update!(status: :starting)
    end
  end

  def run(bulk)
    bulk.update!(status: :starting)
  end

  def stop(bulk)
  end
end
