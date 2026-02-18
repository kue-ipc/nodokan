module Period
  extend ActiveSupport::Concern

  class_methods do
    def period(value)
      case value
      in nil
        nil
      in Integer
        value
      in ActiveSupport::Duration
        value.to_i
      in String
        ActiveSupport::Duration.parse(value).to_i
      else
        raise ArgumentError, "Invalid period value: #{value.inspect}"
      end
    end
  end
end
