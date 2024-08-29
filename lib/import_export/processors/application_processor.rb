require "active_support"

module ImportExport
  module Processors
    class ApplicationProcessor
      # class method
      #   class_name
      #   params_permit
      #   convert_map

      class << self
        attr_reader :model, :keys, :get_map, :set_map

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@get_map, {}.with_indifferent_access)
          subclass.instance_variable_set(:@set_map, {}.with_indifferent_access)
        end

        def class_name(name)
          @model = name.constantize
        end

        def params_permit(*args, **kwargs)
          @keys = normalize_keys([*args, kwargs])
        end

        def normalize_keys(keys)
          return keys if keys == []
          return keys if keys == {}

          keys = [keys] unless keys.is_a?(Array)
          keys.compact.map do |key|
            case key
            in Symbol
              key
            in Hash
              key.transform_values { |v| normalize_keys(v) }
            end
          end
        end

        def converter(key, original_key = nil, get: nil, set: nil)
          get ||= original_key || key
          @get_map[key] = get.to_proc

          set ||= original_key || key
          set = :"#{set}=" if set.is_a?(Symbol) && !set.end_with?("=")
          @set_map[key] = set.to_proc
        end
      end

      def initialize(user = nil)
        @user = user
      end

      def current_user
        @user
      end

      def model
        self.class.model
      end

      def keys
        self.class.keys
      end

      def key_converter(key, method)
        case method
        in :get
          self.class.get_map[key] || key.to_proc
        in :set
          self.class.set_map[key] || :"#{key}=".to_proc
        end
      end

      def record_ids
        if current_user
          Pundit.policy_scope(current_user, model).order(:id).pluck(:id)
        else
          model.order(:id).pluck(:id)
        end
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
            params << record_to_params(r, keys: keys)
          end
        else
          params ||= {}.with_indifferent_access
          keys.each do |key|
            case key
            in Symbol
              params[key] = convert_value(get_param(record, key))
            in Hash
              key.each do |k, v|
                params[k] = record_to_params(get_param(record, k),
                  params: params[k], keys: v)
              end
            end
          end
        end
        params
      end

      def params_to_record(params, record: nil, keys: self.keys)
        record ||= model.new(initial_model_attributes)
        permitted_params = ActionController::Parameters.new(params).permit(*keys)
        permitted_params.each do |key, value|
          set_param(record, key, value)
        end
        record
      end

      private def get_param(record, key)
        instance_exec(record, &key_converter(key, :get))
      end

      private def set_param(record, key, param)
        instance_exec(record, param, &key_converter(key, :set))
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

      def create(params)
        user_process(nil, :create) do |record|
          record.transaction do
            params_to_record(params, record: record)
            record.save || raise(ActiveRecord::Rollback)
          end
        end
      end

      def read(id)
        user_process(id, :read)
      end

      def update(id, params)
        user_process(id, :update) do |record|
          record.transaction do
            params_to_record(params, record: record)
            record.save || raise(ActiveRecord::Rollback)
          end
        end
      end

      def delete(id)
        user_process(id, :delete, &:destroy)
      end

      # authorize and whodunnit
      def user_process(id, method, in_trail: false, &block)
        if !in_trail && current_user
          PaperTrail.request(whodunnit: current_user.email) do
            return user_process(id, method, in_trail: true, &block)
          end
        end

        record = if id
          model.find(id)
        else
          model.new(initial_model_attributes)
        end

        if current_user
          policy = Pundit.policy(current_user, record)
          auth = case method
          in :create then policy.create?
          in :read then policy.show?
          in :update then policy.update?
          in :delete then policy.destroy?
          end
          unless auth
            raise Pundit::NotAuthorizedError,
              "not allowed to #{method} this record"
          end
        end

        block&.call(record)
        record
      end

      private def initial_model_attributes
        nil
      end
    end
  end
end
