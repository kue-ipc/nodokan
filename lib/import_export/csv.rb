require "fileutils"
require "logger"

require "import_export/batch"

module ImportExport
  class Csv < Batch
    class InvalidHeaderError < StandardError
    end

    class InvalidFieldError < StandardError
    end

    content_type "text/csv"
    extname ".csv"

    attr_reader :result, :count

    def initialize(*, out: +"", with_bom: false, delimiter: "\n", **)
      # FIXME: 3.0系では`super`と引数無しで呼び出した場合、
      #        `opts`にout等が一緒に入るため、オプションを付ける。
      super(*, **)

      if with_bom
        out = StringIO.new(out) if out.is_a?(String)
        out << "\u{feff}"
      end
      @csv = CSV.new(out, headers:, write_headers: true, **)
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

    def params_each_row(params, &)
      rows = [empty_row]
      put_in_rows(rows, params)
      rows.each(&)
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
                parent: key_to_header(key.singularize, parent:))
            end
            rows.replace(new_rows)
          else
            rows.each do |row|
              row[key_to_header(key, parent:)] =
                value.map(&:to_s).join(@delimiter)
            end
          end
        in Hash
          put_in_rows(rows, value, parent: key)
        in String | Symbol | Numeric | true | false |
          Date | Time | DateTime
          rows.each do |row|
            row[key_to_header(key, parent:)] = value.to_s
          end
        end
      end
      rows
    end

    def headers
      @headers ||=
        ["id", *headers_from_keys(@processor.keys), "[result]", "[message]"]
    end

    def headers_from_keys(keys, parent: nil)
      keys.flat_map do |key|
        case key
        in Symbol
          key_to_header(key, parent:)
        in Hash
          key.flat_map do |k, v|
            if v == []
              key_to_header(k, parent:)
            else
              headers_from_keys(v,
                parent: key_to_header(k.to_s.singularize, parent:))
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

    def header_row(headers_or_row = headers)
      headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
      CSV::Row.new(headers_or_row, headers_or_row, true)
    end

    def empty_row(headers_or_row = headers)
      headers_or_row = headers_or_row.headers if headers_or_row.is_a?(CSV::Row)
      CSV::Row.new(headers_or_row, [])
    end

    def delimiter
      "\n"
    end

    def parse_data_each_params(data)
      CSV.table(data, converters: [], header_converters: :downcase,
        encoding: "BOM|UTF-8").each do |row|
        yield row_to_params(row)
      end
    end

    def row_to_params(row, params: nil, keys: @processor.keys)
      params ||= {}.with_indifferent_access
      row.to_hash.compact_blank.each do |key, value|
        next if key =~ /\A\[\w+\]\z/

        if key == "id"
          params["id"] = value
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
            cur_params[parent] ||= {}.with_indifferent_access
            # next
            cur_keys = single_keys
            cur_params = cur_params[parent]
            key = :"#{child}#{descendants}"
          elsif (multiple_keys = find_key_in_keys(parent.pluralize, cur_keys))
            # multiple
            cur_params[parent.pluralize] ||= [{}.with_indifferent_access]
            # next
            cur_keys = multiple_keys
            cur_params = cur_params[parent.pluralize].first
            key = :"#{child}#{descendants}"
          else
            raise InvalidHeaderError, "Header is not match keys: #{key}"
          end
        end
        if key !~ /\A\w+\z/
          raise InvalidHeaderError, "Header is invalid format: #{key}"
        end

        value = nil if value == "!"

        cur_params[key] =
          if cur_keys.include?(key.intern)
            value
          elsif (nested_key = find_key_in_keys(key, cur_keys))
            case nested_key
            when []
              value.to_s.split
            when {}
              JSON.parse(value.to_s)
            else
              raise InvalidHeaderError, "Header is not nested: #{key}"
            end
          else
            raise InvalidHeaderError, "Header is not included in keys: #{key}"
          end
      end
      params
    end

    def find_key_in_keys(key, keys)
      key = key.intern
      keys.grep(Hash).find { |k| k.key?(key) }&.fetch(key)
    end
  end
end
