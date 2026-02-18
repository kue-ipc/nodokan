require "fileutils"
require "logger"
require "yaml"

require "import_export/batch"

module ImportExport
  class Yaml < Batch
    content_type "application/yaml"
    extname ".yaml"

    attr_reader :result, :count

    YAML_OPTIONS = %i[indentation line_width canonical header stringify_names].freeze

    def initialize(*, **opts)
      super(*, **opts.except(*YAML_OPTIONS))
      @yaml_opts = {stringify_names: true}.merge(opts.slice(*YAML_OPTIONS))

      @data = []
    end

    # override
    def out
      if @data
        YAML.safe_dump(@data, @out, **@yaml_opts)
        @data = nil
      end
      @out
    end

    private def add_to_out(params)
      @data << safe_object(params)
    end

    private def safe_object(obj)
      case obj
      when true, false, nil, Numeric
        obj
      when String, Symbol
        obj.to_s
      when Hash
        obj.to_hash.transform_values { |value| safe_object(value) }
      when Array
        obj.map { |value| safe_object(value) }
      else
        obj.to_s
      end
    end

    private def parse_data_each_params(data)
      YAML.safe_load(data, symbolize_names: true).each do |params|
        yield params
      end
    end
  end
end
