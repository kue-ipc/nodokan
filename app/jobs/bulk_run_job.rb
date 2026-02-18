require "stringio"
require "csv"

class BulkRunJob < ApplicationJob
  class DuplicateRunError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  discard_on DuplicateRunError, BulkRunError

  def perform(bulk, retry_count = 10)
    batch = nil

    PaperTrail.request.disable_model(Bulk)
    if bulk.input.attached? && bulk.input.content_type.nil?
      if bulk.input.analized?
        raise BulkRunError, "Do not know content type of input file after analized"
      end

      retry_count -= 1
      if retry_count.negative?
        raise BulkRunError, "Do not analyze input file or unknown content type"
      end

      Rails.logger.warn { "Retry bulk run Bulk##{bulk.id}, remain count: #{retry_count}" }
      BulkRunJob.set(wait: 10.seconds).perform_later(bulk, retry_count)
      return
    end

    batch = start(bulk)
    run(bulk, batch)
    stop(bulk, batch)
  rescue DuplicateRunError
    # do nothing
    raise
  rescue StandardError => e
    # rubocop:disable Rails/SkipsModelValidations
    bulk.update_attribute(:status, :error)
    # rubocop:enable Rails/SkipsModelValidations
    Rails.logger.error(e.full_message)
    begin
      attach_output(bulk, batch)
    rescue
      io = StringIO.new(e.message)
      bulk.output.attach(io:, filename: "error.txt", content_type: "text/plain", identify: false)
    end
    raise BulkRunError, e.message
  end

  def start(bulk)
    unless bulk.waiting?
      raise DuplicateRunError, "Bulk status is not waiting: Bulk##{bulk.id}"
    end

    bulk.update!(status: :starting)

    if bulk.input.attached?
      if bulk.content_type.nil?
        bulk.update!(content_type: bulk.input.content_type)
      elsif bulk.content_type != bulk.input.content_type
        raise BulkRunError, "Content type mismatch: #{bulk.content_type} != #{bulk.input.content_type}"
      end
    end

    processor =
      case bulk.target
      when "Node"
        ImportExport::Processors::NodesProcessor.new(bulk.user)
      when "Confirmation"
        ImportExport::Processors::ConfirmationsProcessor.new(bulk.user)
      when "Network"
        ImportExport::Processors::NetworksProcessor.new(bulk.user)
      when "User"
        ImportExport::Processors::UsersProcessor.new(bulk.user)
      else
        raise BulkRunError, "Unknow target: #{bulk.target}"
      end
    batch =
      case Mime::Type.lookup(bulk.content_type).symbol
      when :csv
        ImportExport::Csv.new(processor, with_bom: true)
      when :yaml
        ImportExport::Yaml.new(processor)
      when :jsonl
        ImportExport::Jsonl.new(processor)
      else
        raise BulkRunError, "Unknown content type: #{bulk.content_type}"
      end

    bulk_number =
      if bulk.input.attached?
        bulk.input.open do |file|
          batch.import(file, noop: true)
        end
      else
        batch.export(noop: true)
      end
    bulk.update!(number: bulk_number)
    batch
  end

  # rubocop: disable Rails/SkipsModelValidations
  # TODO: cancelで停止できるようにする。
  def run(bulk, batch)
    bulk.update!(status: :running)

    if bulk.input.attached?
      bulk.input.open do |file|
        batch.import(file) do |result|
          case result
          when :created, :read, :updated, :deleted
            bulk.increment!(:success)
          when :failed, :error
            bulk.increment!(:failure)
          else
            raise BulkRunError, "Unknown export result: #{result}"
          end
        end
      end
    else
      batch.export do |result|
        case result
        when :read
          bulk.increment!(:success)
        when :failed, :error
          bulk.increment!(:failure)
        else
          raise BulkRunError, "Unknown export result: #{result}"
        end
      end
    end
  rescue StandardError
    # maybe not count failure, so increment failure
    bulk.increment!(:failure)
    raise
  end
  # rubocop: enable Rails/SkipsModelValidations

  def stop(bulk, batch)
    bulk.update!(status: :stopping)
    attach_output(bulk, batch)
    bulk.reload
    if bulk.failure.positive?
      bulk.update!(status: :failed)
    elsif bulk.success.positive?
      bulk.update!(status: :succeeded)
    else
      bulk.update!(status: :nothing)
    end
  end

  private def attach_output(bulk, batch)
    return if bulk.output.attached?

    io = batch.out
    io.close_write
    io.rewind
    filename_prefix = bulk.input.filename&.base || bulk.target.underscore
    filename = filename_prefix + Time.current.strftime("_%Y%m%d%H%M%S") + batch.extname
    bulk.output.attach(io:, filename:, content_type: batch.content_type, identify: false)
  end
end
