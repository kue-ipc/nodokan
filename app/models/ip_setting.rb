# TODO
class IpSetting
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :setting, :string
  attribute :address, :string
  attribute :nemask, :string
  attribute :prefix_length, :integer
  attribute :gateway, :string
end
