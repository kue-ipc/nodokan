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
    PaperTrail.request.disable_model(Bulk)
    if bulk.input.attached? && bulk.input.content_type.nil?
      if bulk.input.analized?
        raise BulkRunError,
          "Do not know content type of input file after analized"
      end

      retry_count -= 1
      if retry_count.negative?
        raise BulkRunError,
          "Do not analyze input file or unknown content type"
      end

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
    attach_output(bulk, batch) if batch && !bulk.output.attached?
    bulk.reload
    bulk.update(status: :error)
    Rails.logger.error(e.full_message)
    raise BulkRunError, e.message
  end

  def start(bulk)
    unless bulk.waiting?
      raise DuplicateRunError, "Bulk status is not waiting: Bulk##{bulk.id}"
    end

    bulk.update!(status: :starting)

    # TODO: 今のところtext/csvのみ。
    #     将来はxlsxとかも対応したい。
    if bulk.input.attached?
      if bulk.input.content_type != "text/csv"
        raise BulkRunError, "Unknown content type: #{bulk.file.content_type}"
      end

      bulk_number = bulk.input.open do |file|
        CSV.table(file, encoding: "BOM|UTF-8").size
      end
      bulk.update!(number: bulk_number)
    end

    processor =
      case bulk.target
      when "Node"
        ImportExport::Processors::NodesProcessor.new(bulk.user)
      when "Confirmation"
        raise BulkRunError, "Not implemented target: #{bulk.target}"
        # ImportExport::Processors::ConfirmationsProcessor.new(bulk.user)
      when "Network"
        ImportExport::Processors::NetworksProcessor.new(bulk.user)
      when "User"
        ImportExport::Processors::UsersProcessor.new(bulk.user)
      else
        raise BulkRunError, "Unknow target: #{bulk.target}"
      end
    ImportExport::Csv.new(processor, with_bom: true)
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
    out = batch.out
    out.close_write
    out.rewind
    filename_prefix = bulk.input.filename&.base || bulk.target.underscore
    bulk.output.attach(
      io: out,
      filename: filename_prefix + Time.current.strftime("_%Y%m%d%H%M%S") +
        batch.extname,
      content_type: batch.content_type,
      identify: false)
  end
end
