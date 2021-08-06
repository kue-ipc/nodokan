class Place < ApplicationRecord
  has_many :nodes, dependent: :restrict_with_error

  validates :area, length: { maximum: 255 }
  validates :building, length: { maximum: 255 }
  validates :floor, numericality: {
    only_integer: true,
  }
  validates :room, length: { maximum: 255 }, uniqueness: {
    scope: [:area, :building, :floor],
    case_sensitive: true,
  }

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

  def same
    Place.find_by(
      area: area,
      building: building,
      floor: floor,
      room: room,
    )
  end
end
