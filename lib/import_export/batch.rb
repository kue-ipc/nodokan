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

    def content_type
      self.class.content_type
    end

    def extname
      self.class.extname
    end

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
    def import(data, &block)
      parse_data_each_params(data) do |params|
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
        add_result(params, &block)
      end
    end

    def export(&block)
      @processor.record_all.find_each do |record|
        params = ActiveSupport::HashWithIndifferentAccess.new
        params[:id] ||= record.id
        begin
          @processor.user_process(record, :read) do
            @processor.record_to_params(record, params: params)
            params["[result]"] = :read
          end
        rescue Pundit::NotAuthorizedError
          failed_params(params, I18n.t("errors.messages.not_authorized"))
        rescue StandardError => e
          Rails.logger.error("Export error occured: " \
                             "#{record.model_name.name}##{record.id}")
          Rails.logger.error(e.full_message)
          error_params(params, e.message)
        end
        add_result(params, &block)
      end
    end

    def import_params(params)
      id = params[:id]&.strip
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
