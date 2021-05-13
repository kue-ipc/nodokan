class OperatingSystem < ApplicationRecord
  belongs_to :os_category

  has_many :nodes, dependent: :restrict_with_error

  validates :os_category, presence: true

  validates :name, presence: true,
    length: {maximum: 255}, uniqueness: {case_sensitive: false}

  def os_category_name
    @os_category_name ||= os_category&.name
  end

  def os_category_name=(str)
    if str.present?
      self.os_category = OsCategory.find_or_initialize_by(name: str)
      @os_category_name = os_category&.name
    else
      self.device_type = nil
      @device_type_name = nil
    end
  end
end
