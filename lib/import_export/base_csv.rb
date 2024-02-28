require "fileutils"
require "logger"

module ImportExport
  # BascCsv is abstract class for CSV management
  class BaseCsv
    # abstract methods
    # * model_class()
    # * attrs()
    # * row_to_record(row, record = model_class.new)
    # override methods
    # * record_to_row(record, row = empty_row)

    def initialize(csv_file, logger: Logger.new($stderr))
      @csv_file = csv_file
      @tmp_file = "#{@csv_file}.tmp"
      @logger = logger
    end

    def import
      results = {
        success: 0,
        failure: 0,
        error: 0,
        skip: 0,
      }

      csv = CSV.read(@csv_file, encoding: "BOM|UTF-8", headers: :first_row)

      File.open(@tmp_file, "wb:UTF-8") do |io|
        io.write "\u{feff}"
        io.puts csv.headers.to_csv
        count = 0
        csv.each do |row|
          count += 1
          do_action(row)
        rescue StandardError => e
          row["result"] = :error
          row["message"] = e.message
          @logger.error(e.full_message)
        ensure
          @logger.info("#{count}: [#{row['result']}] #{row['id']}: #{row['message']}")
          results[row["result"]] += 1
          io.puts row.to_csv
        end
      end
      @logger.info("Import CSV RESULTS: #{results.to_json}")

      backup_file = "#{@csv_file}.#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
      FileUtils.move(@csv_file, backup_file) if FileTest.exist?(@csv_file)
      FileUtils.move(@tmp_file, @csv_file)

      results
    end

    def export
      results = {
        success: 0,
        failure: 0,
        error: 0,
        skip: 0,
      }

      File.open(@tmp_file, "wb:UTF-8") do |io|
        io.write "\u{feff}"
        io.puts header.to_csv
        list.each do |row|
          io.puts row.to_csv
          results[:success] += 1
        end
      end
      @logger.info("Export CSV RESULTS: #{results.to_json}")

      backup_file = "#{@csv_file}.#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
      FileUtils.move(@csv_file, backup_file) if FileTest.exist?(@csv_file)
      FileUtils.move(@tmp_file, @csv_file)

      results
    end

    def do_action(row)
      model_class.transaction do
        if row["action"].blank?
          row["result"] = :skip
          return
        end

        success, message =
          case row["action"].first.upcase
          when "C" then create(row)
          when "R" then read(row)
          when "U" then update(row)
          when "D" then delete(row)
          else raise "unknown action: #{row['action']}"
          end

        unless success
          row["result"] = :failure
          row["message"] = message
          raise ActiveRecord::Rollback
        end

        row["action"] = nil
        row["result"] = :success
        row["message"] = nil
      end
      row
    end

    def unique_attrs
      []
    end

    def headers
      @headers ||= ["action", "id", *attrs, "result", "message"]
    end

    def header
      @header ||= CSV::Row.new(headers, headers, true)
    end

    def find(row)
      return model_class.find(row["id"]) if row["id"].present?

      unique_attrs.find { |attr| row[attr.to_s].present? }
        &.then { |attr| model_class.find_by({attr => row[attr.to_s]}) }
    end

    def empty_row(headers_or_row = headers)
      headers_or_row = headers_or_row.headers unless headers_or_row.is_a?(Array)
      CSV::Row.new(headers_or_row, [])
    end

    def delimiter
      " "
    end

    # "abc[def][ghi]" -> ["abc", "def", "ghi"]
    # only \w(0-9a-zA-Z_)
    def key_to_list(key)
      str = key.dup
      list = []
      list << -Regexp.last_match(1) while str.sub!(/\[(\w+)\]\z/, "")
      raise "Invalid key: #{key}" unless str =~ /\A\w+\z/

      [-str, *list.reverse]
    end

    def value_to_csv(value)
      if value.is_a?(Enumerable)
        value.map { |item| value_to_identifier(item) }.join(delimiter)
      else
        value_to_identifier(value)
      end
    end

    def value_to_identifier(value)
      if value.respond_to?(:identifier)
        value.identifier
      elsif value.respond_to?(:to_str)
        value.to_str
      else
        value.to_s
      end
    end

    def record_to_row(record, row = empty_row, keys = attrs)
      keys.each do |key|
        value = record
        key_to_list(key).each do |attr|
          value = value.__send__(attr)
          break if value.nil?
        end
        row[key] = value_to_csv(value)
      end
      row
    end

    def record_to_row_with_id(record, row = empty_row)
      row = record_to_row(record, row)
      row["id"] = value_to_csv(record.id)
      row
    end

    def list
      model_class.order(:id).all.map { |record| record_to_row_with_id(record) }
    end

    def create(row)
      record = model_class.new
      row_to_record(row, record)
      if record.save
        row["id"] = record.id
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end

    def read(row)
      record = find(row)
      return [false, "Not found."] unless record

      row["id"] = record.id
      record_to_row(record, row)
      [true, nil]
    end

    def update(row)
      record = find(row)

      return [false, "Not found."] unless record

      row["id"] = record.id
      row_to_record(row, record)

      if record.save
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end

    def delete(row)
      record = find(row)
      return [false, "Not found."] unless record

      row["id"] = record.id

      if record.destroy
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end
  end
end
