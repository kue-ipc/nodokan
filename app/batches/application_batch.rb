class ApplicationBatch
  # call class methods
  #   conetnt_type ...
  # define instance methods
  #   def each_params(input, &)
  #   def open_output(output, &block)
  #   def puts_params(params, output)

  def self.content_type(str = nil)
    if str.nil?
      @mime_type.to_s
    else
      (@mime_type = Mime::Type.lookup(str)).to_s
    end
  end

  def self.extname
    ".#{@mime_type.symbol}"
  end

  def initialize(processor)
    @processor = processor
  end

  def content_type
    self.class.content_type(nil)
  end

  delegate :extname, to: :class

  private attr_reader :input_params_list

  delegate :count, to: :input_params_list

  def load(input = nil)
    if input
      @input_params_list = []
      open_input(@input) do |desc|
        while (params = gets_params(desc))
          list << params
        end
      end
    else
      @input_params_list = @processor.record_ids.map { |id| {id:} }
    end
  end

  def run(output)
    results = Hash.new(0)
    open_output(output) do |desc|
      input_params_list.each do |params|
        params = do_action(@processor.input_filter(params))
        puts_params(desc, @processor.output_filter(params))
        results[params[:_result]] += 1
        yield params if block_given?
      end
    end
    results
  end

  private def do_action(params)
    case params
    in {_result: _}
      # skip if result is already set
    in {id: Integer, **nil}
      show_record(params)
    in {id: Integer, _destroy: true}
      destroy_record(params)
    in {id: Integer}
      update_record(params)
    in {id: nil}
      create_record(params)
    in {id: _}
      failed_params(params, I18n.t("errors.messages.invalid_params", name: :id))
    else
      create_record(params)
    end
    params
  rescue ActiveRecord::RecordNotFound
    failed_params(params, I18n.t("errors.messages.not_found"))
    params
  rescue Pundit::NotAuthorizedError
    failed_params(params, I18n.t("errors.messages.not_authorized"))
    params
  rescue StandardError => e
    Rails.logger.error("ImporExport do action error occured: #{params.to_json}")
    Rails.logger.error(e.full_message)
    error_params(params, e.message)
    params
  end

  private def show_record(params)
    record = @processor.show(params[:id])
    params.replace({id: record.id, **@processor.serialize(record), _result: "shown"})
    record
  end

  private def create_record(params)
    record = @processor.create(params)
    if record.errors.empty?
      params.replace({id: record.id, **@processor.serialize(record),  _result: "created"})
    else
      failed_params(params, record_error_message(record, "not_saved"))
    end
    record
  end

  private def update_record(params)
    record = @processor.update(params[:id], params)
    if record.errors.empty?
      params.replace({id: record.id, **@processor.serialize(record),  _result: "updated"})
    else
      failed_params(params, record_error_message(record, "not_saved"))
    end
    record
  end

  private def destroy_record(params)
    # get paramms before destruction, because association params may be lost after destruction
    params_before_destruction = @processor.serialize(@processor.show(params[:id]))
    record = @processor.destroy(params[:id])
    if record.errors.empty?
      # no id because it may be reused when creating new record
      params.relpace({**params_before_destruction, _result: "destroyed"})
    else
      failed_params(params, record_error_message(record, "not_destroyed"))
    end
    record
  end

  private def record_error_message(record, key = nil)
    messages = []
    if key
      messages << I18n.t(key, scope: "errors.messages", resource: record, count: record.errors.count)
    end
    messages.concat(record.errors.full_messages)
    messages.join("\n")
  end

  private def failed_params(params, message)
    params[:_result] = "failed"
    params[:_message] = message
  end

  private def error_params(params, message)
    params[:_result] = "error"
    params[:_message] = message
  end

  private def delete_meta_params(params)
    params.reject! { |key, _| key.start_with?("_") }
  end

  private def compact_params(obj)
    case obj
    when true, false, nil, Numeric
      obj
    when String, Symbol
      obj.to_s
    when Hash
      obj.to_h { |key, value| [key.to_s, compact_params(value)] }.compact_blank
    when Array
      obj.map { |value| compact_params(value) }.compact_blank
    else
      obj.to_s
    end
  end
end
