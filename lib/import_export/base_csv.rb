require "fileutils"
require "logger"

module ImportExport
  # BascCsv is abstract class for CSV management
  class BaseCsv
    # abstract methods
    # * model_class()
    # * attrs()
    # * row_to_record(row, record: model_class.new)
    # override methods
    # * record_to_row(record, row: empty_row, keys: attrs)

    attr_reader :output, :result, :count

    def initialize(user = nil, out: String.new, **opts)
      @user = user
      @output = CSV.new(out, headers: headers, write_headers: true, **opts)
      @count = 0
      @result = Hash.new(0)
    end

    def add_result(row)
      status = row["[result]"]
      Rails.logger.debug { "#{@count}: #{status}" }
      @output << row
      @result[status] += 1
      @count += 1
      yiled row[status] if block_given?
    end

    # data is a string or io formatted csv
    def import(data, &block)
      CSV.new(data, headers: :first_row).each_with_index do |row, idx|
        import_row(row)
      rescue Pundit::NotAuthorizedError => e
        row["[result]"] = :failed
        row["[message]"] = I18n.t("messages.forbidden_action",
          model: record.model_name.human,
          action: I18n.t("actions.import"))
      rescue StandardError => e
        row["[result]"] = :error
        row["[message]"] = e.message
        Rails.logger.error("Import error occured: #{idx}")
        Rails.logger.error(e.full_message)
      ensure
        add_result(row, &block)
      end
    end

    def export(records = record_all, &block)
      records.find_each do |record|
        split_row_record(record).each do |record_opts|
          row = nil
          authorize(record, :read)
          row = record_to_row_with_id(record, **record_opts)
          row["[result]"] = :read
        rescue Pundit::NotAuthorizedError => e
          row ||= {}
          row["id"] ||= record.id
          row["[result]"] = :failed
          row["[message]"] = I18n.t("messages.forbidden_action",
            model: record.model_name.human,
            action: I18n.t("actions.export"))
        rescue StandardError => e
          row ||= {}
          row["id"] ||= record.id
          row["[result]"] = :error
          row["[message]"] = e.message
          Rails.logger.error("Export error occured: #{record.id}")
          Rails.logger.error(e.full_message)
        ensure
          add_result(row, &block)
        end
      end
    end

    def record_all
      model_class.order(:id).all
    end

    def split_row_record(_record)
      [{}]
    end

    def import_row(row)
      unless header_set.superset?(row.headers.to_set)
        row["[result]"] = :failed
        row["[message]"] = I18n.t("errors.messages.invalid_csv_header")
        return
      end

      case row["id"]&.strip
      when nil, ""
        record = create(row)
        if record.errors.empty?
          record_to_row_with_id(record, row: row)
          row["[result]"] = :created
        else
          row["[result]"] = :failed
          row["[message]"] =
            I18n.t("errors.messages.not_saved", resource: record,
              count: record.errors.count) +
            record.errors.full_messages.join("\n")
        end
      when /\A\d+\z/
        id = row["id"].strip.to_i
        record = update(id, row)
        if record.nil?
          row["[result]"] = :failed
          row["[message]"] = I18n.t("errors.messages.not_found")
        elsif record.errors.empty?
          record_to_row_with_id(record, row: row)
          row["[result]"] = :updated
        else
          row["[result]"] = :failed
          row["[message]"] =
            I18n.t("errors.messages.not_saved", resource: record,
              count: record.errors.count) +
            record.errors.full_messages.join("\n")
        end
      when /\A!\d+\z/
        id = row["id"].strip.delete_prefix("!").to_i
        record = delete(id)
        if record.nil?
          row["[result]"] = :failed
          row["[message]"] = I18n.t("errors.messages.not_found")
        elsif record.errors.empty?
          record_to_row_with_id(record, row: row)
          row["[result]"] = :deleted
        else
          row["[result]"] = :failed
          row["[message]"] =
            I18n.t("errors.messages.not_deleted", resource: record,
              count: record.errors.count) +
            record.errors.full_messages.join("\n")
        end
      else
        row["[result]"] = :failed
        row["[message]"] = I18n.t("errors.messages.invalid_id_field")
      end
    end

    def headers
      @headers ||= ["id", *attrs, "[result]", "[message]"]
    end

    def header_row
      @header_row ||= CSV::Row.new(headers, headers, true)
    end

    def header_set
      @header_set ||= headers.to_set
    end

    def empty_row(headers_or_row = headers)
      headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
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

    def record_to_row_with_id(record, **opts)
      row = record_to_row(record, **opts)
      row["id"] = record.id
      row
    end

    def record_to_row(record, row: empty_row, keys: attrs, **opts)
      keys.each do |key|
        row_assign(row, record, key, **opts)
      end
      row
    end

    def row_assign(row, record, key, **_opts)
      value = record
      key_to_list(key).each do |attr|
        value = value.__send__(attr)
        break if value.nil?
      end
      row[key] = value_to_field(value)
    end

    def value_to_field(value)
      if value.nil?
        ""
      elsif value.is_a?(Enumerable)
        value.map { |item| value_to_identifier(item) }.join(delimiter)
      else
        value_to_identifier(value)
      end
    end

    def value_to_identifier(value)
      if value.nil?
        ""
      elsif value.respond_to?(:identifier)
        value.identifier
      elsif value.respond_to?(:to_str)
        value.to_str
      else
        value.to_s
      end
    end

    # 値が空白や存在しない場合は上書きしない。
    def row_to_record(row, record: model_class.new, keys: attrs, **opts)
      keys.select { |key| row[key].present? }.each do |key|
        record_assign(record, row, key, **opts)
      end
      record
    end

    # FIXME: key_to_listで分解できるようなkeyは未対応
    def record_assign(record, row, key, **_opts)
      record.assign_attributes(key => row[key])
    end

    def create(row)
      authorize(model_class, :create)
      record = row_to_record(row)
      record.save if record.errors.empty?
      record
    end

    def read(id)
      record = model_class.find_by(id: id)
      authorize(record, :read)
      record
    end

    def update(id, row)
      record = model_class.find_by(id: id)
      return if record.nil?

      authorize(record, :update)
      record.transaction do
        row_to_record(row, record: record)
        record.errors.empty? || raise(ActiveRecord::Rollback)
        record.save || raise(ActiveRecord::Rollback)
      end
      record
    end

    def delete(id)
      record = model_class.find_by(id: id)
      return if record.nil?

      authorize(record, :delete)
      record.destroy
      record
    end

    def authorize(record, method)
      return if @user.nil?

      policy = Pundit.policy(@user, record)
      auth =
        case method
        in :create
          policy.create?
        in :read
          policy.show?
        in :update
          policy.update?
        in :delete
          policy.delete?
        end
      return if auth

      raise Pundit::NotAuthorizedError, "not allowed to #{method} this record"
    end
  end
end
