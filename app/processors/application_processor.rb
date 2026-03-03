class ApplicationProcessor
  # class method
  #   class_name
  #   params_permit
  #   convert_map

  class Converter
    def initialize(key, get: nil, set: nil)
      @key = key.intern
      @get = (get || @key).to_proc
      @set = (set || :"#{@key}=").to_proc
    end
  end

  class << self
    def inherited(subclass)
      super
      converters = Hash.new { |h, k| h[k] = Converter.new(k) }
      subclass.instance_variable_set(:@converters, converters)
    end

    def model_name(name = nil)
      if name
        @model_name = name
      else
        @model_name || raise("Model name is not set for #{self}")
      end
    end

    def model
      @model ||= model_name.constantize
    end

    def keys(list = nil)
      if list
        @keys = list
      else
        @keys || raise("Keys are not set for #{self}")
      end
    end

    def converter(key, original_key = nil, get: nil, set: nil)
      @map[key] = Converter.new(original_key || key, get:, set:)
    end
  end

  attr_reader :user

  def initialize(user = nil)
    @user = user
  end

  def has_privilege?
    user.nil? || user.admin?
  end

  def record_ids
    if user
      Pundit.policy_scope(user, self.class.model).order(:id).pluck(:id)
    else
      self.class.model.order(:id).pluck(:id)
    end
  end

  def serialize(record, keys: self.class.keys)
    params = {}
    each_keys(keys) do |key, permitted|
      value = get_param(record, key)

      case permitted
      in nil | [] | {}
        params[key] = convert_value(value)
      in [[*next_keys]]
        params[key] = []
        value.each do |v|
          params[key] << serialize(v, keys: next_keys)
        end
      in [*]
        params[key] = serialize(value, keys: permitted)
      in {**}
        params[key] = serialize(value, keys: permitted)
      end
    end
    params
  end

  def show(id)
    user_process(id, __method__)
  end

  def create(params)
    user_process(nil, __method__) do |record|
      record.transaction do
        assign_params(params, record:)
        record.save || raise(ActiveRecord::Rollback)
      end
    end
  end

  def update(id, params)
    user_process(id, __method__) do |record|
      record.transaction do
        assign_params(params, record:)
        record.save || raise(ActiveRecord::Rollback)
      end
    end
  end

  def destroy(id)
    user_process(id, __method__, &:destroy)
  end

  private def get_param(record, key)
    instance_exec(record, &self.class.converters[key][:get])
  end

  private def set_param(record, key, param)
    instance_exec(record, param, &self.class.converters[key][:set])
  end

  private def each_keys(keys = self.class.keys, &block)
    return enum_for(__method__, keys) unless block_given?

    keys.each do |key, value|
      case key
      in Symbol
        block.call(key, value)
      in Hash
        each_keys(key, &block)
      end
    end
  end

  private def convert_value(value)
    case value
    in nil | true | false | Integer | Float | String | Time | Date
      value
    in Array
      value.map(&method(:convert_value))
    in Hash
      value.transform_values(&method(:convert_value))
    in ActiveSupport::TimeWithZone | DateTime
      value.to_time
    in ApplicationRecord
      if value.respond_to?(:identifier)
        value.identifier
      else
        {id: value.id}
      end
    else
      value
    end
  end

  # find on new rocerd, authorize record, and yield record with whodunit
  private def user_process(id, method)
    record =
      if id
        self.class.model.find(id)
      else
        self.class.model.new(initial_model_attributes)
      end

    if user
      policy = Pundit.policy(user, record)
      unless policy.__send__(:"#{method}?")
        raise Pundit::NotAuthorizedError, "not allowed to #{method} this record"
      end
    end

    if block_given?
      if user
        PaperTrail.request(whodunnit: user.email) do
          yield record
        end
      else
        yield record
      end
    end

    record
  end

  private def initial_model_attributes
    nil
  end

  private def assign_params(record, params)
    permitted_params = ActionController::Parameters.new({params:}).expect(params: self.class.keys)
    permitted_params.each do |key, value|
      Rails.logger.debug { "Processing param: #{key} = #{value.inspect}" }
      set_param(record, key.intern, value)
    end
    record
  end
end
