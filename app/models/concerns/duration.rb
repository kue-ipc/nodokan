module Duration
  extend ActiveSupport::Concern

  def duration(value)
    case value
    in ActiveSupport::Duration
      value
    in Integer
      value.seconds
    in String
      ActiveSupport::Duration.parse(value)
    in nil
      nil
    else
      raise ArgumentError, "Invalid duration value: #{value.inspect}"
    end
  end
end
