require "stringio"

class ApplicationBatch
  # call class methods
  #   conetnt_type ...
  #   exname ...
  # define instance methods
  #   def add_to_out(params)
  #   def parse_data_each_params(data)

  def self.content_type(str = nil)
    return @content_type if str.nil?

    @content_type = str
  end

  def self.extname(str = nil)
    return @extname if str.nil?

    @extname = str
  end

  delegate :content_type, to: :class

  delegate :extname, to: :class

  attr_reader :result, :count, :out

  def initialize(processor, out: StringIO.new)
    @processor = processor
    @out = if out.is_a?(String)
      StringIO.new(+out)
    else
      out
    end
    @count = 0
    @result = Hash.new(0)
  end

  # data is a string or io formatted csv
  def import(data, noop: false, &)
    count = 0
    parse_data_each_params(data) do |params|
      count += 1
      next if noop

      do_action(params)
      add_result(params, &)
    end
    count
  end

  def export(noop: false, &)
    count = 0
    @processor.record_ids.each do |id|
      count += 1
      next if noop

      params = {id:, _action_: "read"}
      do_action(params)
      add_result(params, &)
    end
    count
  end

  private def do_action(params)
    # skip if result is already set
    return if params[:_result_].present?

    if params[:_action_].blank?
      params[:_action_] =
        if params[:id].present?
          "update"
        else
          "create"
        end
    end

    case params
    in {_action_: "create"}
      create_record(params)
    in {id: Integer, _action_: "read"}
      read_record(params)
    in {id: Integer, _action_: "update"}
      update_record(params)
    in {id: Integer, _action_: "delete"}
      delete_record(params)
    else
      failed_params(params, I18n.t("errors.messages.invalid_params", name: :_action_))
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

  private def add_result(params)
    status = params[:_result_]
    Rails.logger.debug { "#{@count}: #{status}" }
    add_to_out(params)
    @result[status] += 1
    @count += 1
    yield status if block_given?
  end

  private def create_record(params)
    record = @processor.create(params)
    if record.errors.empty?
      @processor.record_to_params(record, params:)
      params[:id] = record.id
      params[:_result_] = "created"
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
    params[:_result_] = "read"
    params.delete(:_action_)
    record
  end

  private def update_record(params)
    record = @processor.update(params[:id], params)
    if record.errors.empty?
      @processor.record_to_params(record, params:)
      params[:id] = record.id
      params[:_result_] = "updated"
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
      params[:_result_] = "deleted"
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
    params[:_result_] = "failed"
    params[:_message_] = message
  end

  private def error_params(params, message)
    params[:_result_] = "error"
    params[:_message_] = message
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
