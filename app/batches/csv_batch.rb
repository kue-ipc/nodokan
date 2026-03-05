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
  def open_input(input, &)
    CSV.open(input, headers: true, header_converters: :downcase, encoding: "BOM|UTF-8", **@csv_opts, &)
  end

  def gets_params(csv)
    csv.gets&.then { |row| row_to_params(row) }
  end

  private def row_to_params(row)
    params = {}

    row.to_hash.compact_blank.each do |key, value|
      if key.start_with?(/\W/)
        Rails.logger.warn "Ignore header that dose not start with word char: #{key}"
        next
      end

      if key == "id"
        case value.strip
        when /\A\d+\z/
          params[:id] = value.to_i
        when /\A!\d+\z/
          params[:id] = value.delete_prefix("!").to_i
          params[:_destroy] = true
        else
          params[:id] = value
        end

        next
      end

      value = nil if value == "!"

      cur_params = params
      keys = split_key(key).map do |k|
        if k.empty?
          nil
        elsif k =~ /\A\d+\z/
          k.to_i
        else
          k.intern
        end
      end

      while keys.present?
        cur_key = keys.shift
        case keys
        in []
          # a
          cur_params[cur_key] = value
        in [nil]
          # a[]
          keys.shift
          cur_params[cur_key] = value&.split
        in [Integer]
          # a[0]
          number = keys.shift
          cur_params[cur_key] = []
          cur_params[cur_key][number] = value
        in [nil | Integer, Symbol, *]
          # a[][c] or  a[0][c]
          number = keys.shift.to_i
          cur_params[cur_key] ||= []
          cur_params[cur_key][number] ||= {}
          cur_params = cur_params[cur_key][number]
        in [Symbol, *]
          # a[b]
          cur_params[cur_key] ||= {}
          cur_params = cur_params[cur_key]
        else
          raise InvalidHeaderError, "Header is invalid pattern: #{key}"
        end
      end
    end
    params
  end

  private def split_key(key)
    if (m = /\A(\w*)\[(\w*)\]((?:\[\w*\])*)\z/.match(key))
      [m[1], *split_key("#{m[2]}#{m[3]}")]
    elsif key =~ /\A\w*\z/
      [key]
    else
      raise InvalidHeaderError, "Header is invalid format: #{key}"
    end
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
    add_to_rows(rows, params)
    rows.each(&)
  end

  # TODO ここを修正中
  private def add_to_rows(rows, params, parent: nil)
    params.each do |key, value|
      case value
      in true | false | nil | Integer | Float | String
        rows.each do |row|
          row[key_to_header(key, parent:)] = value.to_s
        end
        obj
      in String
        obj.to_s
      in Hash
        add_to_rows(rows, value, parent: key)
      in Array
        value = value.compact_blank
        if value.first.is_a?(Hash)
          new_rows = value.flat_map do |hash|
            add_to_rows(rows.map(&:clone), hash, parent: key_to_header(key.to_s.singularize, parent:))
          end
          rows.replace(new_rows)
        else
          rows.each do |row|
            row[key_to_header(key, parent:)] = value.map(&:to_s).join(@delimiter)
          end
        end
      else
        Rails.logger.warn("Unknown type in params vaule: #{value.class}, value: #{value.inspect}")
      end

      when Array
      when Hash
      else
      end
    end
    rows
  end

  # csv
  private def headers
    @headers ||= ["id", *headers_from_keys(@processor.class.keys), "_result", "_message"]
  end

  private def headers_from_keys(keys, parent: nil)
    keys.flat_map do |key|
      case key
      in Symbol
        key_to_header(key, parent:)
      in Hash
        key.flat_map do |k, v|
          parent_key = key_to_header(k, parent:)
          case v
          in []
            key_to_header("", parent: parent_key)
          in [[*]]
            headers_from_keys(v.first, parent: key_to_header("", parent: parent_key))
          in [*]
            headers_from_keys(v, parent: parent_key)
          in {**}
            headers_from_keys([v], parent: parent_key)
          end
        end
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
