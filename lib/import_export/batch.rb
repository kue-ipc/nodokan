require "active_support"

module ImportExport
  class Batch
    # call class methods
    #   conetnt_type ...
    #   exname ...
    # define instance methods
    #   def add_to_out(params)
    #   def parse_data_each_params(data)
    #   def out

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

    attr_reader :result, :count

    def initialize(processor, **_opts)
      @processor = processor
      @count = 0
      @result = Hash.new(0)
    end

    def add_result(params)
      status = params["[result]"]
      Rails.logger.debug { "#{@count}: #{status}" }
      add_to_out(params)
      @result[status] += 1
      @count += 1
      yield status if block_given?
    end

    # data is a string or io formatted csv
    def import(data, noop: false, &)
      count = 0
      parse_data_each_params(data) do |params|
        count += 1
        next if noop

        begin
          import_params(params) unless noop
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
          params["[result]"] = :read
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

    def import_params(params)
      id = params[:id]
      id = id.strip if id.is_a?(String)
      case id
      when nil, ""
        record = @processor.create(params)
        if record.errors.empty?
          params["[result]"] = :created
          params["[message]"] = record.id
        else
          failed_params(params, record_error_message(record, "not_saved"))
        end
      when Integer, /\A\d+\z/
        id = id.to_i
        record = @processor.update(id, params)
        if record.errors.empty?
          params["[result]"] = :updated
        else
          failed_params(params, record_error_message(record, "not_saved"))
        end
      when /\A!\d+\z/
        id = id.delete_prefix("!").to_i
        record = @processor.delete(id)
        if record.errors.empty?
          params["[result]"] = :deleted
        else
          failed_params(params, record_error_message(record, "not_deleted"))
        end
      else
        failed_params(params, I18n.t("errors.messages.invalid_id_param"))
      end
      params
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
      params["[result]"] = :failed
      params["[message]"] = message
    end

    private def error_params(params, message)
      params["[result]"] = :error
      params["[message]"] = message
    end
  end
end
