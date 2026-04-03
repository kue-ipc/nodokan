# class method
#   class_name
#   params_permit
#   convert_map
class ApplicationProcessor
  include Pundit::Authorization

  class Converter
    attr_reader :key, :get, :set, :nested_converters

    def initialize(key, get: nil, set: nil)
      @key = key.intern
      @get = (get || @key).to_proc
      @set = (set || :"#{@key}=").to_proc
      @nested_converters = Hash.new { |h, k| h[k] = Converter.new(k) }
    end
  end

  class StrictParameters < ActionController::Parameters
    # override to raise error when unpermitted parameter is included
    def permit(*filters)
      permit_filters(filters, on_unpermitted: :raise, explicit_arrays: true)
    end
  end

  class << self
    def converters
      @converters ||= Hash.new { |h, k| h[k] = Converter.new(k) }
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

    def array_keys
      @array_keys ||= keys.select do |key, permitted|
        case permitted
        in [[*]]
          true
        in {**}
          true
        else
          false
        end
      end.map { |key, _| key }
    end

    def array_of_hashes_keys

    end

    def converter(key, original_key = nil, get: nil, set: nil, nested: nil)
      converters[key] = Converter.new(original_key || key, get:, set:)
      nested&.each do |nested_key, nested_option|
        converters[key].nested_converters[nested_key] =
          case nested_option
          in Hash => opts
            Converter.new(nested_key, **opts)
          in [Symbol => original_key, Hash => opts]
            Converter.new(original_key, **opts)
          in [Symbol => original_key]
            Converter.new(original_key)
          in Symbol => original_key
            Converter.new(original_key)
          end
      end
    end
  end

  delegate :converters, to: :class
  delegate :model, to: :class
  # rubocop: disable Rails/Delegate
  def keys = self.class.keys
  def allow_nil_keys = self.class.allow_nil_keys
  # rubocop: enable Rails/Delegate

  attr_reader :user
  alias current_user user

  def initialize(user = nil)
    @user = user
  end

  def serialize(record, keys: self.keys, converters: self.converters)
    return if record.nil?

    params = {}
    each_keys(keys) do |key, permitted|
      value = get_param(record, key, converters)
      case permitted
      in nil | [] | {} # scalar, array, hash
        params[key] = convert_value(value)
      in [[*next_keys]] # array of records
        params[key] = []
        value.each do |v|
          params[key] << serialize(v, keys: next_keys, converters: converters[key].nested_converters)
        end
      in [*] | {**} # record
        params[key] = serialize(value, keys: permitted, converters: converters[key].nested_converters)
      end
    end
    params
  end

  def all
    if current_user
      authorize model, "index?"
      policy_scope(model).all
    else
      model.all
    end
  end

  def ids = all.ids # rubocop: disable Rails/Delegate

  def index = all.to_a

  def show(id)
    user_process(id, __method__)
  end

  def create(params)
    user_process(nil, __method__) do |record|
      record.transaction do
        assign_params(record, params)
        record.save!
      end
    end
  end

  def update(id, params)
    user_process(id, __method__) do |record|
      record.transaction do
        assign_params(record, params)
        record.save!
      end
    end
  end

  def destroy(id)
    user_process(id, __method__, &:destroy!)
  end

  private def get_param(record, key, converters)
    instance_exec(record, &converters[key].get)
  end

  private def set_param(record, key, param, converters)
    instance_exec(record, param, &converters[key].set)
  end

  private def each_keys(keys = self.keys, &block)
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
    in ActiveSupport::TimeWithZone | DateTime
      value.to_time
    in Hash
      value.transform_values(&method(:convert_value))
    in Enumerable
      value.map(&method(:convert_value))
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
        model.find(id)
      else
        model.new(initial_model_attributes)
      end

    authorize record, "#{method}?" if current_user

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
    permitted_params = permit_params(params)
    permitted_params.each do |key, value|
      Rails.logger.debug { "Processing param: #{key} = #{value.inspect}" }
      set_param(record, key.intern, value, converters)
    end
    record
  end

  private def permit_params(params)
    params = params.deep_dup
    skip_params = delete_skip_params(params)
    permitted_params = StrictParameters.new(params).permit(keys)
    permitted_params.deep_merge!(skip_params) do |key, old_val, new_val|
      if (old_val in [StrictParameters, *]) && (new_val in [Hash, *])
        old_val.zip(new_val).map do |old_item, new_item|
          if old_item.is_a?(StrictParameters) && new_item.is_a?(Hash)
            old_item.deep_merge!(new_item)
          else
            new_item
          end
        end
      else
        new_val
      end
    end
    permitted_params
  end

  private def delete_skip_params(params, keys = self.keys)
    return unless params.is_a?(Hash)

    skip_params = {}
    skip_params[:_destroy] = params.delete(:_destroy) if params.key?(:_destroy)
    each_keys(keys) do |key, permitted|
      if params.key?(key)
        case permitted
        in nil # scalor
          # do nothing
        in [] # array of scalors
          skip_params[key] = params.delete(key)
        in [[*next_keys]] # array of hashes
          if params[key].nil?
            skip_params[key] = params.delete(key)
          elsif params[key].is_a?(Array)
            skip_params[key] = []
            params[key].each do |sub_params|
              skip_params[key] << delete_skip_params(sub_params, next_keys)
            end
          end
        in [*] | {**} # hash
          if params[key].nil?
            skip_params[key] = params.delete(key)
          else
            skip_params[key] = delete_skip_params(params[key], permitted)
          end
        end
      end
    end
    skip_params
  end
end
