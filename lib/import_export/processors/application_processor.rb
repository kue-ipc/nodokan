require "active_support"

module ImportExport
  module Processors
    class ApplicationProcessor
      def self.model(model = nil)
        return @model if model.nil?

        @model = model
      end

      def model
        self.class.model
      end

      def self.keys(*args, **kwargs)
        return @keys if args.empty? && kwargs.empty?

        hash = {}
        @keys = []
        args.each do |arg|
          case args
          in Simbol
            @keys << arg
          in String
            @keys << arg.intern
          in Hash
            hash.deep_merge!(arg)
          end
        end
        hash.deep_merge!(kwargs)
        @keys << hash.freeze
      end

      def keys
        self.class.keys
      end

      def initialize(user = nil)
        @user = user
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
          params = record
        else
          params ||= ActiveSupport::HashWithIndifferentAccess.new
          keys.each do |key|
            case key
            in Symbol
              params[key] = get_param(record, key)
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
        params = ActiveController::Parameter.new(params).permit(*keys)
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
        record.__send__(key)
      end

      def set_param(record, key, param)
        record.__send__("#{key}=", param)
      end

      # # "abc[def][ghi]" -> ["abc", "def", "ghi"]
      # def key_to_list(key)
      #   list = []
      #   while (m = /\A([^\[]*)\[([^\]]*)\](.*)\z/.match(key))
      #     list << m[1]
      #     key = m[2] + m[3]
      #   end
      #   list << key
      #   list
      # end

      # # ["abc", "def", "ghi"] -> "abc[def][ghi]"
      # def list_to_key(list)
      #   tmp = list.dup
      #   str = tmp.shift.dup
      #   str << "[#{tmp.shift}]" until tmp.empty?
      #   str
      # end

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
