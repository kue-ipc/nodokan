# name attribute must be unique, not blank, 255 characters or less, case insensitive,
#   and stripped of surrounding whitespace.
module UniqueName
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true, length: {maximum: 255}, uniqueness: {case_sensitive: false}
    normalizes :name, with: :strip.to_proc
  end

  class_methods do
    def read_identifier(record) = record.identifier
    def find_identifier(str) = find_by!(name: str.to_s.strip)
  end

  def identifier = name
end
