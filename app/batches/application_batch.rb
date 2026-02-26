require "stringio"

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

  def content_type
    self.class.content_type(nil)
  end

  delegate :extname, to: :class

  def initialize(processor, input, output)
    @processor = processor
    @input = input
    @output = output
  end

  delegate :count, to: :input_params_list

  private def input_params_list
    @input_params ||= if @input
      list = []
      open_input(@input) do |desc|
        while (params = gets_params(desc))
          list << params
        end
      end
      list
    else
      @processor.record_ids.map { |id| {id:} }
    end
  end

  def run
    results = Hash.new(0)
    open_output do |desc|
      input_params_list.each do |params|
        do_action(params)
        puts_params(desc, params)
        results[params[:_result]] += 1
        yield params[:_result] if block_given?
      end
    end
    results
  end

  private def do_action(params)
    case params
    in {_result: _}
      # skip if result is already set
    in {id: Integer, **nil}
      read_record(params)
    in {id: Integer, _destroy: true}
      delete_record(params)
    in {id: Integer}
      update_record(params)
    in {id: nil}
      create_record(params)
    in {id: _}
      failed_params(params, I18n.t("errors.messages.invalid_params", name: :id))
    else
      create_record(params)
    end
  rescue ActiveRecord::RecordNotFound
    failed_params(params, I18n.t("errors.messages.not_found"))
  rescue Pundit::NotAuthorizedError
    failed_params(params, I18n.t("errors.messages.not_authorized"))
  rescue StandardError => e
    Rails.logger.error("ImporExport do action error occured: #{params.to_json}")
    Rails.logger.error(e.full_message)
    error_params(params, e.message)
  end

  private def create_record(params)
    record = @processor.create(params)
    if record.errors.empty?
      @processor.record_to_params(record, params:)
      params[:id] = record.id
      params[:_result] = "created"
      params.delete(:_action_)
    else
      failed_params(params, record_error_message(record, "not_saved"))
    end
    record
  end

  private def read_record(params)
    record = @processor.read(params[:id])
    @processor.record_to_params(record, params:)
    params[:id] = record.id
    params[:_result] = "read"
    params.delete(:_action_)
    record
  end

  private def update_record(params)
    record = @processor.update(params[:id], params)
    if record.errors.empty?
      @processor.record_to_params(record, params:)
      params[:id] = record.id
      params[:_result] = "updated"
      params.delete(:_action_)
    else
      failed_params(params, record_error_message(record, "not_saved"))
    end
    record
  end

  private def delete_record(params)
    # NOTE: Get paramms before deletion for export, because some params may be lost after deletion (e.g. associations)
    params_before_deletion = @processor.record_to_params(@processor.read(params[:id]))
    record = @processor.delete(params[:id])
    if record.errors.empty?
      params.merge!(params_before_deletion)
      params.delete(:id) # delete id because it may be reused when creating new record
      params[:_result] = "deleted"
      params.delete(:_action_)
    else
      failed_params(params, record_error_message(record, "not_deleted"))
    end
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
