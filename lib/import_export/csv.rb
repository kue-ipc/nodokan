require "fileutils"
require "logger"

require "import_export/batch"

module ImportExport
  class Csv < Batch
    class InvalidFieldError < StandardError
    end

    content_type "text/csv"
    extname ".csv"

    attr_reader :result, :count

    def initialize(*args, out: String.new, with_bom: false, delimiter: "\n",
      **opts)
      # FIXME: 3.0系では`super`と引数無しで呼び出した場合、
      #        `opts`にout等が一緒に入るため、オプションを付ける。
      super(*args, **opts)

      if with_bom
        out = StringIO.new(out) if out.is_a?(String)
        out << "\u{feff}"
      end
      @csv = CSV.new(out, headers: headers, write_headers: true, **opts)
      @delimiter = delimiter
    end

    def out
      @csv.to_io
    end

    def add_to_out(params)
      params_each_row(params) do |row|
        @csv << row
      end
    end

    def each_params(data)
    end

    def params_each_row(params, &block)
      rows = [empty_row]
      put_in_rows(rows, params)
      rows.each(&block)
    end

    def put_in_rows(rows, params, parent: nil)
      params.each do |key, value|
        next if value.blank?

        case value
        in Array
          value = value.compact_blank
          if value.first.is_a?(Hash)
            new_rows = value.flat_map do |hash|
              put_in_rows(rows.map(&:clone), hash,
                parent: key_to_header(key.singularize, parent: parent))
            end
            rows.replace(new_rows)
          else
            rows.each do |row|
              row[key_to_header(key, parent: parent)] =
                value.map(&:to_s).join(@delimiter)
            end
          end
        in Hash
          put_in_rows(rows, value, parent: key)
        in String | Symbol | Numeric | true | false |
          Date | Time | DateTime
          rows.each do |row|
            row[key_to_header(key, parent: parent)] = value.to_s
          end
        end
      end
      rows
    end

    # def add_result(row)
    #   status = row["[result]"]
    #   Rails.logger.debug { "#{@count}: #{status}" }
    #   @csv << row
    #   @result[status] += 1
    #   @count += 1
    #   yield status if block_given?
    # end

    # # data is a string or io formatted csv
    # def import(data, **opts, &block)
    #   PaperTrail.request(whodunnit: @user&.email) do
    #     CSV.new(data, headers: :first_row, **opts).each_with_index do |row, idx|
    #       import_row(row)
    #     rescue Pundit::NotAuthorizedError
    #       row["[result]"] = :failed
    #       row["[message]"] = I18n.t("messages.forbidden_action",
    #         model: record.model_name.human,
    #         action: I18n.t("actions.import"))
    #     rescue StandardError => e
    #       row["[result]"] = :error
    #       row["[message]"] = e.message
    #       Rails.logger.error("Import error occured: #{idx}")
    #       Rails.logger.error(e.full_message)
    #     ensure
    #       add_result(row, &block)
    #     end
    #   end
    # end

    # def export(records = nil, &block)
    #   PaperTrail.request(whodunnit: @user&.email) do
    #     records.find_each do |record|
    #       split_row_record(record).each do |record_opts|
    #         row = nil
    #         authorize(record, :read)
    #         row = record_to_row_with_id(record, **record_opts)
    #         row["[result]"] = :read
    #       rescue Pundit::NotAuthorizedError
    #         row ||= {}
    #         row["id"] ||= record.id
    #         row["[result]"] = :failed
    #         row["[message]"] = I18n.t("messages.forbidden_action",
    #           model: record.model_name.human,
    #           action: I18n.t("actions.export"))
    #       rescue StandardError => e
    #         row ||= {}
    #         row["id"] ||= record.id
    #         row["[result]"] = :error
    #         row["[message]"] = e.message
    #         Rails.logger.error("Export error occured: #{record.id}")
    #         Rails.logger.error(e.full_message)
    #       ensure
    #         add_result(row, &block)
    #       end
    #     end
    #   end
    # end

    # def split_row_record(_record)
    #   [{}]
    # end

    # def each_params(data)
    #   CSV.new(data, headers: :first_row, **opts).each_with_index do |row, idx|
    #     unless header_set.superset?(row.headers.to_set)
    #     row["[result]"] = :failed
    #     row["[message]"] = I18n.t("errors.messages.invalid_csv_header")
    #     return
    #   end

    #   case row["id"]&.strip
    #   when nil, ""
    #     record = create(row)
    #     if record.errors.empty?
    #       record_to_row_with_id(record, row: row)
    #       row["[result]"] = :created
    #     else
    #       row["[result]"] = :failed
    #       row["[message]"] =
    #         I18n.t("errors.messages.not_saved", resource: record,
    #           count: record.errors.count) +
    #         record.errors.full_messages.join("\n")
    #     end
    #   when /\A(\d+)\z/
    #     id = ::Regexp.last_match(1).to_i
    #     record = update(id, row)
    #     if record.nil?
    #       row["[result]"] = :failed
    #       row["[message]"] = I18n.t("errors.messages.not_found")
    #     elsif record.errors.empty?
    #       record_to_row_with_id(record, row: row)
    #       row["[result]"] = :updated
    #     else
    #       row["[result]"] = :failed
    #       row["[message]"] =
    #         I18n.t("errors.messages.not_saved", resource: record,
    #           count: record.errors.count) +
    #         record.errors.full_messages.join("\n")
    #     end
    #   when /\A!(\d+)\z/
    #     id = ::Regexp.last_match(1).to_i
    #     record = delete(id)
    #     if record.nil?
    #       row["[result]"] = :failed
    #       row["[message]"] = I18n.t("errors.messages.not_found")
    #     elsif record.errors.empty?
    #       record_to_row_with_id(record, row: row)
    #       row["[result]"] = :deleted
    #     else
    #       row["[result]"] = :failed
    #       row["[message]"] =
    #         I18n.t("errors.messages.not_deleted", resource: record,
    #           count: record.errors.count) +
    #         record.errors.full_messages.join("\n")
    #     end
    #   else
    #     row["[result]"] = :failed
    #     row["[message]"] = I18n.t("errors.messages.invalid_id_field")
    #   end
    # end

    def headers(keys = @processor.keys)
      @headers ||= ["id", *headers_from_keys(keys), "[result]", "[message]"]
    end

    def headers_from_keys(keys, parent: nil)
      keys.flat_map do |key|
        case key
        in Symbol
          key_to_header(key, parent: parent)
        in Hash
          key.map do |k, v|
            if v == []
              key_to_header(key, parent: parent)
            else
              keys_to_headers(v, parent: key_to_header(key, parent: parent))
            end
          end
        end
      end
    end

    def key_to_header(key, parent: nil)
      if parent
        "#{parent}[#{key}]"
      else
        key.to_s
      end
    end

    # def header_row
    #   @header_row ||= CSV::Row.new(headers, headers, true)
    # end

    # def header_set
    #   @header_set ||= headers.to_set
    # end

    def empty_row(headers_or_row = headers)
      headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
      CSV::Row.new(headers_or_row, [])
    end

    def delimiter
      "\n"
    end

    # def row_to_params(row, keys: attrs)
    #   params = {}
    #   row.to_hash.slice(*keys).compact_blank.each do |key, value|
    #     current = params
    #     *list, last = key_to_list(key)
    #     list.each do |name|
    #       current = (current[name.intern] ||= {})
    #       raise "Invalid nested key: #{key}" unless current.is_a?(Hash)
    #     end
    #     current[last.intern] = value
    #   end
    #   params
    # end

    # def record_to_row_with_id(record, **opts)
    #   row = record_to_row(record, **opts)
    #   row["id"] = record.id
    #   row
    # end

    # def record_to_row(record, row: empty_row, keys: attrs, **opts)
    #   keys.each do |key|
    #     row_assign(row, record, key, **opts)
    #   end
    #   row
    # end

    # # 値が空白や存在しない場合は上書きしない。
    # def row_to_record(row, record: model_class.new, keys: attrs, **opts)
    #   keys.select { |key| row[key].present? }.each do |key|
    #     record_assign(record, row, key, **opts)
    #   end
    #   record
    # end

    # def record_assign(record, row, key, **_opts)
    #   *list, last = key_to_list(key)
    #   list.each do |name|
    #     record = record.__send__(name)
    #   end
    #   record.assign_attributes(last => row[key])
    # end
  end
end
