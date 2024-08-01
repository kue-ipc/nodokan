require "stringio"

class BulkRunJob < ApplicationJob
  class DuplicateRunError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  discard_on DuplicateRunError, BulkRunError

  def perform(bulk)
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
    unless bulk.waiting?
      raise DuplicateRunError, "Bulk status is not waiting: Bulk##{bulk.id}"
    end

    bulk.update!(status: :starting)

    return unless bulk.input.attached?

    if bulk.input.content_type != "text/csv"
      raise BulkRunError, "Unknown content type: #{bulk.file.content_type}"
    end

    if bulk.number.zero?
      bulk.input.open do |file|
        bulk.update!(number: file.each_line.drop(1).count)
      end
    end
  end

  def run(bulk)
    bulk.update!(status: :running)
  end

  def stop(bulk)
    bulk.update!(status: :stopping)
    if bulk.failure.posivive?
      bulk.update!(status: :failed)
    elsif bulk.success.positive?
      bulk.update!(status: :succeeded)
    else
      bulk.update!(status: :nothing)
    end
  end
end
