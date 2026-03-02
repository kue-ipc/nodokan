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

    def each_key
      return enum_for(__method__) unless block_given?

      keys.each do |key|
        case key
        in Symbol
          yield key, nil
        in Hash
          key.each do |k, v|
            yield k, v
          end
        end
      end
    end

    def converter(key, original_key = nil, get: nil, set: nil)
      @map[key] = Converter.new(original_key || key, get:, set:)
    end
  end

  delegate :model, to: :class
  delegate :keys, to: :class
  delegate :each_key, to: :class
  delegate :converters, to: :class

  attr_reader :user

  def initialize(user = nil)
    @user = user
  end

  def has_privilege?
    user.nil? || user.admin?
  end

  def record_ids
    if user
      Pundit.policy_scope(user, model).order(:id).pluck(:id)
    else
      model.order(:id).pluck(:id)
    end
  end

  def get_param(record, key)
    instance_exec(record, &self.class.converters[key][:get])
  end

  def set_param(record, key, param)
    instance_exec(record, param, &self.class.converters[key][:set])
  end

  def serialize(record)
    params = {}
    each_key do |key, value|
      case vavule
      in nil
      in []
      in {}
      in [[*]]
      in [*]
      in {**}
      end
      if value.nil?
        params[key] = convert_value(get_param(record, key))
      else
        # TODO: ここで、ネストされた情報をうまく出す方法がまだかけていない。
        key.transform_values do |v|
          record_to_params(get_param(record, key), keys: v)
        end
      end
    end
    params
  end

  def record_to_params(record, params: nil, keys: self.keys)
    if record.nil?
      # do nothing
    elsif keys == []
      # scalar array
      params ||= []
      params.concat(convert_value(record))
    elsif record.is_a?(Enumerable)
      params ||= []
      record.each do |r|
        params << record_to_params(r, keys:)
      end
    else
      params ||= {}
      keys.each do |key|
        case key
        in Symbol
          params[key] = convert_value(get_param(record, key))
        in Hash
          key.each do |k, v|
            params[k] = record_to_params(get_param(record, k), params: params[k], keys: v)
          end
        end
      end
    end
    params
  end

  private def assign_params(record, params)
    permitted_params = ActionController::Parameters.new({params:}).expect(params: keys)
    permitted_params.each do |key, value|
      Rails.logger.debug { "Processing param: #{key} = #{value.inspect}" }
      set_param(record, key.intern, value)
    end
    record
  end

  private def convert_value(value)
    case value
    in Hash
      value.transform_values(&method(:convert_value))
    in Enumerable
      value.map(&method(:convert_value))
    in ApplicationRecord
      if value.respond_to?(:identifier)
        value.identifier
      else
        value.to_s
      end
    else
      value
    end
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

  # find on new rocerd, authorize record, and yield record with whodunit
  private def user_process(id, method)
    record =
      if id
        model.find(id)
      else
        model.new(initial_model_attributes)
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
end
