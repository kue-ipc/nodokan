require "stringio"
require "csv"

class BulkRunJob < ApplicationJob
  class NotReadyAttachementError < StandardError
  end

  class DuplicatedError < StandardError
  end

  class CancelledError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  retry_on NotReadyAttachementError do |job, error|
    bulk = job.arguments.first
    bulk.update_attribute(:status, :error) # rubocop:disable Rails/SkipsModelValidations
    io = StringIO.new(error.message)
    bulk.output.attach(io:, filename: "error.txt", content_type: "text/plain", identify: false)
  end

  discard_on DuplicatedError, CancelledError, BulkRunError

  def perform(bulk)
    batch = nil
    out = nil

    PaperTrail.request.disable_model(Bulk)

    check_content_type(bulk)
    batch = build_batch(bulk)
    out = StringIO.new
    start(bulk, batch, out)
    run(bulk, batch, out)
    stop(bulk, batch, out)
  rescue NotReadyAttachementError
    # retry
    Rails.logger.warn(e.message)
    raise
  rescue DuplicatedError
    # log only, do not retry
    Rails.logger.error(e.message)
    raise
  rescue CancelledError
    # log only, do not retry
    Rails.logger.info(e.message)
    raise
  rescue StandardError => e
    Rails.logger.error(e.full_message)
    bulk.update_attribute(:status, :error) # rubocop:disable Rails/SkipsModelValidations
    out ||= StringIO.new
    out << e.message
    begin
      attach_output(bulk, out, force: true)
    rescue => attach_e
      Rails.logger.error(attach_e.full_message)
      io = StringIO.new(e.message + "\n" + attach_e.message)
      bulk.output.attach(io:, filename: "error.txt", content_type: "text/plain", identify: false)
    end
    raise BulkRunError, e.message
  ensure
    out&.close
  end

  def check_content_type(bulk)
    if bulk.input.attached?
      if bulk.input.content_type.nil?
        raise NotReadyAttachementError, "Content type is not determined yet"
      elsif bulk.content_type.nil?
        bulk.update!(content_type: bulk.input.content_type)
      elsif bulk.content_type != bulk.input.content_type
        raise BulkRunError, "Content type mismatch: #{bulk.content_type} != #{bulk.input.content_type}"
      end
    elsif bulk.content_type.nil?
      raise BulkRunError, "Content type is required when input file is not attached"
    end
  end

  def build_batch(bulk)
    processor = "#{bulk.target.camelize.pluralize}Processor".constantize.new(bulk.user)
    "#{bulk.mime_type.symbol.to_s.camelize}Batch".constantize.new(processor)
  end

  def start(bulk, batch, _out)
    unless bulk.waiting?
      raise DuplicatedError, "Bulk status is not waiting: Bulk##{bulk.id}"
    end

    bulk.update!(status: :starting)

    if bulk.input.attached?
      bulk.input.open do |file|
        batch.load(file)
      end
    else
      batch.load
    end

    bulk.update!(number: batch.count)
  end

  def run(bulk, batch, out)
    raise CancelledError, "Bulk is cancelled: Bulk##{bulk.id}" if Bulk.exists?(id: bulk.id, status: :cancel)
    bulk.update!(status: :running)
    batch.run(out) do |params|
      case params
      in {_result: "created" | "shown" | "updated" |  "destroyed"}
        bulk.increment!(:success) # rubocop: disable Rails/SkipsModelValidations
      in {_result: "failed" | "error"}
        bulk.increment!(:failure) # rubocop: disable Rails/SkipsModelValidations
      else
        raise BulkRunError, "Unknown run result: #{params[:_result]}"
      end
      raise CancelledError, "Bulk is cancelled: Bulk##{bulk.id}" if Bulk.exists?(id: bulk.id, status: :cancel)
    end
  rescue CancelledError
    # not count failure
    raise
  rescue StandardError
    # maybe not count failure, so increment failure
    bulk.increment!(:failure) # rubocop: disable Rails/SkipsModelValidations
    raise
  end

  def stop(bulk, batch, out)
    bulk.update!(status: :stopping)
    attach_output(bulk, out)

    bulk.reload
    if bulk.failure.positive?
      bulk.update!(status: :failed)
    elsif bulk.success.positive?
      bulk.update!(status: :succeeded)
    else
      bulk.update!(status: :nothing)
    end
  end

  private def attach_output(bulk, out, force: false)
    return if !force && bulk.output.attached?

    out.close_write
    out.rewind
    filename_prefix = bulk.input.filename&.base || bulk.target
    filename = filename_prefix + Time.current.strftime("_%Y%m%d%H%M%S") + (bulk.extname || ".txt")
    bulk.output.attach(io: out, filename:, content_type: bulk.content_type, identify: false)
  end
end
