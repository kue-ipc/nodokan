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

    def initialize(**opts)
      @result = CSV.new("", headers: headers, write_headers: true, **opts)
    end

    def output
      @result.string
    end

    # data is a string or io formatted csv
    def import(data)
      counts = Hash.new(0)

      CSV.new(data, headers: :first_row).each_with_index do |row, idx|
        do_action(row)
      rescue StandardError => e
        row["result"] = :error
        row["message"] = e.message
        Rails.logger.error("Import error occured: #{idx}")
        Rails.logger.error(e.full_message)
      ensure
        Rails.logger.debug do
          "#{idx}: [#{row['result']}] #{row['id']}: #{row['message']}"
        end
        @result << row
        counts[row["result"]] += 1
      end
      Rails.logger.info("Import CSV: #{counts.to_json}")
      counts
    end

    def export(records = record_all)
      counts = Hash.new(0)

      records.find_each do |record|
        row = nil
        row = record_to_row_with_id(record)
        row["result"] = :success
      rescue StandardError => e
        row ||= {"id" => record.id}
        row["result"] = :error
        row["message"] = e.message
        Rails.logger.error("Export error occured: #{record.id}")
        Rails.logger.error(e.full_message)
      ensure
        @result << row
        counts[row["result"]] += 1
      end
      Rails.logger.info("Export CSV: #{counts.to_json}")
      counts
    end

    def record_all
      model_class.order(:id).all
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
      @headers ||= ["id", *attrs, "result", "message"]
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
      "\n"
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
