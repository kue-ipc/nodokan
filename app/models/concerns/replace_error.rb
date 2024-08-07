module ReplaceError
  extend ActiveSupport::Concern

  private def replace_error(from, to)
    errors[from].each do |msg|
      errors.add(to, msg)
    end
    errors.delete(from)
  end
end
