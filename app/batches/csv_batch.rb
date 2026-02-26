require "csv"

class CsvBatch < ApplicationBatch
  class InvalidHeaderError < StandardError
  end

  class InvalidFieldError < StandardError
  end

  content_type "text/csv"

  CSV_OPTIONS = %i[col_sep row_sep quote_char field_size_limit skip_blanks force_quotes skip_lines].freeze

  def initialize(*, with_bom: true, delimiter: " ", **opts)
    super(*, **opts.except(*CSV_OPTIONS))

    @with_bom = with_bom
    @delimiter = delimiter
    @csv_opts = opts.slice(*CSV_OPTIONS)
  end

  # read
  def open_input(input)
    yield CSV.new(input, headers: true, header_converters: :downcase, encoding: "BOM|UTF-8", **@csv_opts)
  end

  def gets_params(csv)
    csv.gets&.then { |row| row_to_params(row) }
  end

  private def row_to_params(row)
    params = {}
    keys = @processor.keys

    row.to_hash.compact_blank.each do |key, value|
      if key.start_with?(/\W/)
        Rails.logger.warn "Ignore header that dose not start with word char: #{key}"
        next
      end

      next if key.start_with?("_")

      if key == "id"
        case value.strip
        when /\A\d+\z/
          params[:id] = value.to_i
        when /\A!\d+\z/
          params[:id] = value.delete_prefix("!").to_i
          params[:_destroy] = true
        else
          params[:_result] = "failed"
          params[:_message] = I18n.t("errors.messages.invalid_param", name: :id)
        end

        next
      end

      cur_params = params
      cur_keys = keys
      while (m = /\A(\w+)\[(\w+)\]((?:\[\w+\])*)\z/.match(key))
        parent = m[1]
        child = m[2]
        descendants = m[3]
        if (single_keys = find_key_in_keys(parent, cur_keys))
          # single
          cur_params[parent] ||= {}
          # next
          cur_keys = single_keys
          cur_params = cur_params[parent]
          key = "#{child}#{descendants}"
        elsif (multiple_keys = find_key_in_keys(parent.pluralize, cur_keys))
          # multiple
          cur_params[parent.pluralize] ||= [{}]
          # next
          cur_keys = multiple_keys
          cur_params = cur_params[parent.pluralize].first
          key = "#{child}#{descendants}"
        else
          raise InvalidHeaderError, "Header is not match keys: #{key}"
        end
      end

      if key !~ /\A\w+\z/
        raise InvalidHeaderError, "Header is invalid format: #{key}"
      end

      value = nil if value == "!"

      cur_params[key.intern] =
        if cur_keys.include?(key.intern)
          value
        elsif (nested_key = find_key_in_keys(key, cur_keys))
          case nested_key
          when []
            value.split
          when {}
            JSON.parse(value, symbolize_names: true)
          else
            raise InvalidHeaderError, "Header is not nested: #{key}"
          end
        else
          raise InvalidHeaderError, "Header is not included in keys: #{key}"
        end
    end
    params
  end

  private def find_key_in_keys(key, keys)
    key = key.intern
    keys.grep(Hash).find { |k| k.key?(key) }&.fetch(key)
  end

  # write
  def open_output(output)
    output << "\u{feff}" if @with_bom && output.pos.zero?
    yield CSV.new(output, headers:, write_headers: true, **@csv_opts)
  end

  def puts_params(csv, params)
    params_each_row(params) do |row|
      csv << row
    end
  end

  private def params_each_row(params, &)
    rows = [empty_row]
    put_in_rows(rows, params)
    rows.each(&)
  end

  private def put_in_rows(rows, params, parent: nil)
    params.each do |key, value|
      next if value.blank?

      case value
      when Array
        value = value.compact_blank
        if value.first.is_a?(Hash)
          new_rows = value.flat_map do |hash|
            put_in_rows(rows.map(&:clone), hash, parent: key_to_header(key.to_s.singularize, parent:))
          end
          rows.replace(new_rows)
        else
          rows.each do |row|
            row[key_to_header(key, parent:)] = value.map(&:to_s).join(@delimiter)
          end
        end
      when Hash
        put_in_rows(rows, value, parent: key)
      else
        rows.each do |row|
          row[key_to_header(key, parent:)] = value.to_s
        end
      end
    end
    rows
  end

  # csv
  private def headers
    @headers ||= ["id", *headers_from_keys(@processor.keys), "_action_", "_result", "_message"]
  end

  private def headers_from_keys(keys, parent: nil)
    keys.flat_map do |key|
      if key.is_a?(Hash)
        key.flat_map do |k, v|
          if v == []
            key_to_header(k, parent:)
          else
            headers_from_keys(v, parent: key_to_header(k.to_s.singularize, parent:))
          end
        end
      else
        key_to_header(key, parent:)
      end
    end
  end

  private def key_to_header(key, parent: nil)
    if parent
      "#{parent}[#{key}]"
    else
      key.to_s
    end
  end

  private def header_row(headers_or_row = headers)
    headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
    CSV::Row.new(headers_or_row, headers_or_row, true)
  end

  private def empty_row(headers_or_row = headers)
    headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
    CSV::Row.new(headers_or_row, [])
  end

end
