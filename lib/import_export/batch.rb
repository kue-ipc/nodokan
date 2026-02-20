require "stringio"
require "active_support"

module ImportExport
  class Batch
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

        begin
          import_params(params)
        rescue ActiveRecord::RecordNotFound
          failed_params(params, I18n.t("errors.messages.not_found"))
        rescue Pundit::NotAuthorizedError
          failed_params(params, I18n.t("errors.messages.not_authorized"))
        rescue StandardError => e
          Rails.logger.error("Import error occured: #{params.to_json}")
          Rails.logger.error(e.full_message)
          error_params(params, e.message)
        ensure
          add_result(params, &)
        end
      end
      count
    end

    def export(noop: false, &)
      count = 0
      @processor.record_ids.each do |id|
        count += 1
        next if noop

        params = {id:}.with_indifferent_access
        begin
          record = @processor.read(id)
          @processor.record_to_params(record, params:)
          params["_result_"] = :read
        rescue Pundit::NotAuthorizedError
          failed_params(params, I18n.t("errors.messages.not_authorized"))
        rescue StandardError => e
          Rails.logger.error("Export error occured: " \
                             "#{record.model_name.name}##{record.id}")
          Rails.logger.error(e.full_message)
          error_params(params, e.message)
        ensure
          add_result(params, &)
        end
      end
      count
    end

    private def add_result(params)
      status = params["_result_"]
      Rails.logger.debug { "#{@count}: #{status}" }
      add_to_out(params)
      @result[status] += 1
      @count += 1
      yield status if block_given?
    end


    private def import_params(params)
      id = params[:id]
      id = id.strip if id.is_a?(String)
      case id
      when nil, ""
        create_record(params)
      when Integer, /\A\d+\z/
        update_record(id.to_i, params)
      when /\A!\d+\z/
        delete_record(id.delete_prefix("!").to_i, params)
      else
        failed_params(params, I18n.t("errors.messages.invalid_id_param"))
      end
      params
    end

    private def create_record(params)
      record = @processor.create(params)
      if record.errors.empty?
        @processor.record_to_params(record, params:)
        params["_result_"] = :created
      else
        failed_params(params, record_error_message(record, "not_saved"))
      end
      record
    end

    private def update_record(id, params)
      record = @processor.update(id, params)
      if record.errors.empty?
        @processor.record_to_params(record, params:)
        params["_result_"] = :updated
      else
        failed_params(params, record_error_message(record, "not_saved"))
      end
      record
    end

    private def delete_record(id, params)
      # NOTE: Get paramms before deletion for export, because some params may be lost after deletion (e.g. associations)
      params_before_deletion = @processor.record_to_params(@processor.read(id))
      record = @processor.delete(id)
      if record.errors.empty?
        params.merge!(params_before_deletion)
        params.delete("id") # delete id because it may be reused when creating new record
        params["_result_"] = :deleted
      else
        failed_params(params, record_error_message(record, "not_deleted"))
      end
    end

    private def record_error_message(record, key = nil)
      messages = []
      if key
        messages << I18n.t(key, scope: "errors.messages", resource: record,
          count: record.errors.count)
      end
      messages.concat(record.errors.full_messages)
      messages.join("\n")
    end

    private def failed_params(params, message)
      params["_result_"] = :failed
      params["_message_"] = message
    end

    private def error_params(params, message)
      params["_result_"] = :error
      params["_message_"] = message
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
end
