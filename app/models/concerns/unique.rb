# name attribute must be unique, not blank, 255 characters or less, case insensitive,
#   and stripped of surrounding whitespace.
module Unique
  extend ActiveSupport::Concern

  class_methods do
    def unique(attr, maximum: 255, case_sensitive: false, normalize: nil)
      validates attr, presence: true, length: {maximum:}, uniqueness: {case_sensitive:}
      normalize = normalize.to_proc if normalize
      normalizes attr, with: normalize if normalize

      define_singleton_method(:read_identifier) do |record|
        record[attr]
      end

      define_singleton_method(:find_identifier) do |str|
        str = normalize.call(str) if normalize
        find_by!(attr => str)
      end
    end
  end

  def identifier
    self.class.read_identifier(self)
  end
end
