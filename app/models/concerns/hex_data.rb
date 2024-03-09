module HexData
  extend ActiveSupport::Concern

  DEFAULT_CHAR_CASE = :upper
  DEFAULT_SEP = -"-"
  DEFAULT_IGNORE_CHARS = -"-:"

  class_methods do
    def hex_data_to_list(data)
      data&.unpack("C*")
    end

    def hex_list_to_data(list)
      list&.pack("C*")
    end

    def hex_data_to_str(data, **opts)
      hex_list_to_str(hex_data_to_list(data), **opts)
    end

    def hex_str_to_data(str, ignore_chars: DEFAULT_IGNORE_CHARS)
      return if str.nil?

      deleted_str = str.delete(ignore_chars)
      if deleted_str !~ /\A(?:\h{2})*\z/
        raise ArgumentError, "must be pair hex chars: #{str}"
      end

      [str.delete(ignore_chars)].pack("H*")
    end

    def hex_list_to_str(list, char_case: :upper, sep: "-")
      return if list.nil?

      hex =
        case char_case.intern
        when :upper
          "%02X"
        when :lower
          "%02x"
        else
          raise ArgumentError, "invalid char_case: #{char_case}"
        end
      format_str = [[hex] * list.size].join(sep || "")
      format_str % list
    end

    def hex_str_to_list(str, **opts)
      hex_data_to_list(hex_str_to_data(str, **opts))
    end
  end
end
