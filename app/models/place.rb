class Place < ApplicationRecord
  has_many :nodes, dependent: :restrict_with_error

  def name
    [area, building, floor_human, room].select(&:present?).join(' ')
  end

  def floor_human
    if floor.zero?
      ''
    elsif floor.positive?
      "#{floor}階"
    else
      "地下#{-floor}階"
    end
  end
end
