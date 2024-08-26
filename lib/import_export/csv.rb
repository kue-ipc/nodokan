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
              key_to_header(k, parent: parent)
            else
              headers_from_keys(v, parent: key_to_header(k, parent: parent))
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
      CSV.table(data, encoding: "BOM|UTF-8").each do |row|
        yield row_to_params(row)
      end
    end

    def row_to_params(row, params: nil, keys: @processor.keys)
      params ||= {}.with_indifferent_access
      row.to_hash.compact_blank.each do |key, value|
        cur_params = params
        cur_keys = keys
        while (m = /\A([^\[]+)\[([^\[]*)\]((?:\[[^\[]*\])*)\z/.match(key))
          parent = m[1].intern
          child = m[2]
          descendants = m[3]
          cur_params[parent] ||= {}.with_indifferent_access
          # next
          cur_params = cur_params[parent]
          cur_keys = cur_keys.find { |k| k.is_a?(Hash) && k.key?(parent) }
            &.fetch(parent, [])
          key = :"#{child}#{descendants}"
        end
        if key =~ /\[|\]/
          raise InvalidHeaderError, "'[|]' must not be included in header"
        end

        cur_params[key] =
          if cur_keys.any? { |k| k.is_a?(Hash) && k[key] == [] }
            value.to_s.split
          else
            value
          end
      end
      params
    end
  end
end
