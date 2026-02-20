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

      @list = []
    end

    # override
    def out
      if @list
        YAML.safe_dump(@list, @out, **@yaml_opts)
        @list = nil
      end
      @out
    end

    private def add_to_out(params)
      @list << compact_params(params)
    end

    private def parse_data_each_params(data)
      YAML.safe_load(data, symbolize_names: true).each do |params|
        yield params
      end
    end
  end
end
