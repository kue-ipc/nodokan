require "stringio"

class BulkRunJob < ApplicationJob
  class DuplicateRunError < StandardError
  end

  class BulkRunError < StandardError
  end

  queue_as :default

  discard_on DuplicateRunError, BulkRunError

  def perform(bulk)
    csv = start(bulk)
    run(bulk, csv)
    stop(bulk, csv)
  rescue DuplicateRunError
    # nothing
    raise
  rescue StandardError => e
    if csv && !bulk.autput.atteched?
      output = csv.output
      output.close_write
      output.rewind
      filename_prefix =
        if bulk.input.attached?
          File.basename(bulk.input.filename, ".*")
        else
          bulk.target.undersoce
        end
      bulk.output.attach(
        io: outuput,
        filename: "#{filename_prefix}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
        content_type: "text/csv", identify: false)
    end
    bulk.update(status: :error)
    raise BulkRunError, e.message
  end

  def start(bulk)
    unless bulk.waiting?
      raise DuplicateRunError, "Bulk status is not waiting: Bulk##{bulk.id}"
    end

    bulk.update!(status: :starting)

    if bulk.input.attached?
      if bulk.input.content_type != "text/csv"
        raise BulkRunError, "Unknown content type: #{bulk.file.content_type}"
      end

      bulk_number = bulk.input.open do |file|
        file.each_line.drop(1).count
      end
      bulk.update!(number: bulk_number)
    end

    io = StringIO.new
    io << "\u{feff}"

    case bulk.target
    when "Node"
      ImportExport::NodeCsv.new(bulk.user, out: io)
    when "Confirmation"
      raise BulkRunError, "Not implemented target: #{bulk.target}"
      # ImportExport::ConfirmationCsv.new(bulk.user, out: io)
    when "Network"
      ImportExport::NetworkCsv.new(bulk.user, out: io)
    when "User"
      ImportExport::UserCsv.new(bulk.user, out: io)
    else
      raise BulkRunError, "Unknow target: #{bulk.target}"
    end
  end

  def run(bulk, csv)
    bulk.update!(status: :running)
    if bulk.input.attached?
      csv.import(bulk.input.file) do |result|
        case result
        when :created, :read, :updated, :deleted
          bulk.increment!(:success)
        when :failed, :error
          bulk.increment!(:failure)
        else
          raise BulkRunError, "Unknown export result: #{result}"
        end
      end
    else
      csv.export(Pundit.policy_scope(user, csv.class.model_class)) do |result|
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

  def stop(bulk, csv)
    bulk.update!(status: :stopping)
    output = csv.output
    output.close_write
    output.rewind
    filename_prefix =
      if bulk.input.attached?
        File.basename(bulk.input.filename, ".*")
      else
        bulk.target.undersoce
      end
    bulk.output.attach(
      io: output,
      filename: "#{filename_prefix}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
      content_type: "text/csv", identify: false)

    if bulk.failure.posivive?
      bulk.update!(status: :failed)
    elsif bulk.success.positive?
      bulk.update!(status: :succeeded)
    else
      bulk.update!(status: :nothing)
    end
  end
end
