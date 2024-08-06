require "stringio"

class BulkRunJob < ApplicationJob
  class DuplicateRunError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  discard_on DuplicateRunError, BulkRunError

  def perform(bulk, retry_count = 10)
    PaperTrail.request.disable_model(Bulk)
    if bulk.input.attached? && !bulk.input.analyzed?
      retry_count -= 1
      raise BulkRunError, "Do not analyze input file " if retry_count.negative?

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
        file.each_line.drop(1).count
      end
      bulk.update!(number: bulk_number)
    end

    case bulk.target
    when "Node"
      ImportExport::NodeCsv.new(bulk.user, with_bom: true)
    when "Confirmation"
      raise BulkRunError, "Not implemented target: #{bulk.target}"
      # ImportExport::ConfirmationCsv.new(bulk.user, with_bom: true)
    when "Network"
      ImportExport::NetworkCsv.new(bulk.user, with_bom: true)
    when "User"
      ImportExport::UserCsv.new(bulk.user, with_bom: true)
    else
      raise BulkRunError, "Unknow target: #{bulk.target}"
    end
  end

  # rubocop: disable Rails/SkipsModelValidations
  # TODO: cancelで停止できるようにする。
  def run(bulk, batch)
    bulk.update!(status: :running)

    if bulk.input.attached?
      bulk.input.open do |data|
        # BOM付きUTF-8として読み込んでUTF-8に変換
        data.set_encoding("BOM|UTF-8", "UTF-8")
        # BOMは手動で削除する必要がある
        first_char = data.getc
        data.ungetc(first_char) unless first_char == "\u{feff}"
        batch.import(data) do |result|
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
