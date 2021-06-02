require 'csv'
require 'fileutils'
require 'logger'

module ImportExport
  class BaseCSV
    def initialize(csv_file, logger: Logger.new($stderr))
      @csv_file = csv_file
      @tmp_file = "#{@csv_file}.tmp"
      @logger = logger
    end

    def import
      results = {
        success:  0,
        failure:  0,
        error: 0,
        skip: 0,
      }

      csv = CSV.read(@csv_file, encoding: 'BOM|UTF-8', headers: :first_row)

      File.open(@tmp_file, 'wb:UTF-8') do |io|
        io.write "\u{feff}"
        io.puts csv.headers.to_csv
        count = 0
        csv.each do |row|
          count += 1
          do_action(row)
        rescue StandardError => e
          row['result'] = :error
          row['message'] = e.message
          @logger.error(e.full_message)
        ensure
          @logger.info("#{count}: [#{row['result']}] #{row['id']}: #{row['message']}")
          results[row['result']] += 1
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
        success:  0,
        failure:  0,
        error: 0,
        skip: 0,
      }

      File.open(@tmp_file, 'wb:UTF-8') do |io|
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
      if row['action'].blank?
        row['result'] = :skip
        return
      end

      success, message =
        case row['action'].first.upcase
        when 'C' then create(row)
        when 'R' then read(row)
        when 'U' then update(row)
        when 'D' then delete(row)
        else raise "unknown action: #{row['action']}"
        end

      if success
        row['action'] = nil
        row['result'] = :success
        row['message'] = nil
      else
        row['result'] = :failure
        row['message'] = message
      end
      row
    end

    def model_class
      raise NotImplementedError
    end

    def attrs
      raise NotImplementedError
    end

    def unique_attrs
      []
    end

    def header
      @header ||=
        (['action', 'id'] + attrs + ['result', 'message']).then { |fields| CSV::Row.new(fields, fields, true) }
    end

    def find(row)
      return model_class.find(row['id']) if row['id'].present?

      unique_attrs.find { |attr| row[attr.to_s].present? }
        &.then { |attr| model_class.find_by({attr => row[attr.to_s]}) }
    end

    def record_to_row(record, row = CSV::Row.new(header.headers, []))
      raise NotImplementedError
    end

    def row_to_record(row, record = model_class.new)
      raise NotImplementedError
    end

    def list
      row_list = []
      model_class.order(:id).all.each do |record|
        row = CSV::Row.new(header.headers, [])
        row['id'] = record.id
        record_to_row(record, row)
        row_list << row
      end
      row_list
    end

    def create(row)
      record = model_class.new
      row_to_record(row, record)
      if record.save
        row['id'] = record.id
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end

    def read(row)
      record = find(row)
      return [false, 'Not found.'] unless record

      row['id'] = record.id
      record_to_row(record, row)
      [true, nil]
    end

    def update(row)
      record = find(row)

      return [false, 'Not found.'] unless record

      row['id'] = record.id

      row_to_record(row, record)

      if record.save
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end

    def delete(row)
      record = find(row)
      return [false, 'Not found.'] unless record

      row['id'] = record.id

      if record.destroy
        [true, nil]
      else
        [false, record.errors.to_json]
      end
    end
  end
end
