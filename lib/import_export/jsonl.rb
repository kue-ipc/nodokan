require "fileutils"
require "logger"
require "json"

require "import_export/batch"



module ImportExport
  class Jsonl < Batch
    content_type "application/jsonl"
    extname ".jsonl"

    attr_reader :result, :count

    JSON_OPTIONS = %i[max_nesting space space_before].freeze

    def initialize(*, delimiter: "\n", **opts)
      super(*, **opts.except(*JSON_OPTIONS))
      @delemiter = delimiter
      @json_opts = opts.slice(*JSON_OPTIONS)
    end

    private def add_to_out(params)
      @out << JSON.generate(params, @json_opts) << @delemiter
    end

    private def parse_data_each_params(data)
      data.each_line do |line|
        yield JSON.parse(line, symbolize_names: true)
      end
    end
  end
end
