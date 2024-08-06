class Place < ApplicationRecord
  has_paper_trail

  has_many :nodes, dependent: :restrict_with_error

  validates :area, length: {maximum: 255}
  validates :building, length: {maximum: 255}
  validates :floor, numericality: {
    only_integer: true,
  }
  validates :room, length: {maximum: 255}, uniqueness: {
    scope: [:area, :building, :floor],
    case_sensitive: true,
  }

  before_destroy

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(area building floor room confirmed nodes_count)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  # rubocop: enable Lint/UnusedMethodArgument

  def name
    [area, building, floor_human, room].select(&:present?).join(" ")
  end

  def short_name
    room.presence || building.presence || area
  end

  def floor_human
    if floor.zero?
      ""
    elsif floor.positive?
      "#{floor}階"
    else
      "地下#{-floor}階"
    end
  end

  def same
    Place.where.not(id: id).find_by(
      area: area,
      building: building,
      floor: floor,
      room: room)
  end
end
