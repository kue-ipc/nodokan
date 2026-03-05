require "json"

class JsonlBatch < ApplicationBatch
  content_type "application/jsonl"

  JSON_OPTIONS = %i[max_nesting space space_before].freeze

  def initialize(*, delimiter: "\n", **opts)
    super(*, **opts.except(*JSON_OPTIONS))

    @delemiter = delimiter
    @json_opts = opts.slice(*JSON_OPTIONS)
  end

  # read
  def open_input(input)
    yield input
  end

  def gets_params(input)
    input.gets&.then { |line| JSON.parse(line, symbolize_names: true).except(:_result, :_message) }
  end

  # write
  def open_output(oputput)
    yield oputput
  end

  def puts_params(output, params)
    output << JSON.generate(params, **@json_opts) << @delemiter
  end
end
