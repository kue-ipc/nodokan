require "json"

module ListJsonData
  extend ActiveSupport::Concern

  class_methods do
    def list_json_data(name, sep: " ", validate: nil, normalize: nil)
      data_name = :"#{name}_data"

      if validate
        validates_each data_name do |record, attr, value|
          value&.each { |v| validate.call(record, attr, v) }
        end
      end

      normalizes data_name, with: ->(list) { list&.map(normalize) } if normalize

      # MariaDBのjson型はlongtext型にすぎず、文字列を返してしまうため、
      # 文字列であれば、JSONとしてパースする必要がある。
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
