require "json"

module JsonData
  extend ActiveSupport::Concern

  class_methods do
    def json_data(name, sep: " ")
      data_name = :"#{name}_data"

      define_method(data_name) do
        parse_if_str(self[data_name])
      end

      define_method(name) do
        __send__(data_name)&.join(sep)
      end

      define_method("#{name}=") do |value|
        __send__("#{data_name}=", split_str(value))
      end
    end
  end

  private def parse_if_str(obj)
    return obj unless obj.is_a?(String)

    JSON.parse(obj)
  rescue JSON::ParserError
    obj
  end

  private def split_str(str)
    return if str.nil?

    str.tr(",;", " ").split
  end
end
