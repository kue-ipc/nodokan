require "active_support"

module ImportExport
  module Processors
    class ApplicationProcessor
      # class method
      # model
      # keys
      # key_map

      def self.model(model = nil)
        return @model if model.nil?

        @model = model
      end

      def self.keys(*args, **kwargs)
        return @keys if args.empty? && kwargs.empty?

        @keys = normalize_keys([*args, kwargs])
      end

      def self.normalize_keys(keys)
        return keys if keys == []
        return keys if keys == {}

        keys = [keys] unless keys.is_a?(Array)
        hash = {}
        normalized = []
        keys.each do |key|
          case key
          in Symbol
            normalized << key
          in Hash
            hash.deep_merge!(key.transform_values { |v| normalize_keys(v) })
          end
        end
        normalized << hash if hash.present?
        normalized.uniq!
        normalized
      end

      def self.convert_map(map = nil)
        return @convert_map if map.nil?

        @convert_map = map
      end

      def initialize(user = nil)
        @user = user
      end

      def model
        self.class.model
      end

      def keys
        self.class.keys
      end

      def convert(key, method)
        proc = self.class.convert_map[key] || key
        proc = proc[method] || key if proc.is_a?(Hash)
        if proc.is_a?(Symbol)
          proc =
            if method == :set
              :"{proc}=".to_proc
            else
              proc.to_proc
            end
        end
        proc
      end

      def record_all
        if @user
          Pundit.policy_scope(@user, model).order(:id)
        else
          model.order(:id).all
        end
      end

      def record_to_params(record, params: nil, keys: self.keys)
        if record.is_a?(Array)
          params ||= []
          record.each do |r|
            params << record_to_params(r, keys: keys)
          end
        elsif keys == []
          # scalar array
          params = convert_value(record)
        else
          params ||= ActiveSupport::HashWithIndifferentAccess.new
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

      def params_to_record(params, record: model.new, keys: self.keys)
        params = ActionController::Parameters.new(params).permit(*keys)
        keys.each do |key|
          case key
          in Symbol
            set_param(record, key, params[key])
          in Hash
            key.each_key do |k|
              set_param(record, k, params[key])
            end
          end
        end
        record
      end

      def get_param(record, key)
        convert(key, :get).call(record)
      end

      def set_param(record, key, param)
        convert(key, :set).call(record, param)
      end

      def convert_value(value)
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
        user_process(params_to_record(params), :create) do |record|
          record.save if record.errors.empty?
        end
      end

      def read(id)
        user_process(model.find(id), :read, &:itself)
      end

      def update(id, params)
        user_process(model.find(id), :update) do |record|
          record.transaction do
            params_to_record(params, record: record)
            record.errors.empty? || raise(ActiveRecord::Rollback)
            record.save || raise(ActiveRecord::Rollback)
          end
        end
      end

      def delete(id)
        user_process(model.find(id), :delete, &:destroy)
      end

      # authorize and whodunnit
      def user_process(record, method)
        if @user.nil?
          yield record
          return record
        end

        policy = Pundit.policy(@user, record)
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

        PaperTrail.request(whodunnit: @user.email) do
          yield record
          return record
        end
      end
    end
  end
end
