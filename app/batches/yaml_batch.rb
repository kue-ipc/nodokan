require "yaml"

class YamlBatch < ApplicationBatch
  content_type "application/yaml"

  YAML_OPTIONS = %i[indentation line_width canonical header stringify_names].freeze

  def initialize(*, **opts)
    super(*, **opts.except(*YAML_OPTIONS))

    @yaml_opts = {}.merge(opts.slice(*YAML_OPTIONS))
  end

  # read
  def open_input(input)
    yield YAML.safe_load(input, symbolize_names: true)
  end

  def gets_params(data)
    data.shift&.except(:_result, :_message)
  end

  # write
  def open_output(output)
    list = []
    yield list
  ensure
    YAML.safe_dump(list, output, stringify_names: true, **@yaml_opts)
  end

  def puts_params(list, params)
    list << compact_params(params)
  end
end
