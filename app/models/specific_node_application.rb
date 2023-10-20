class SpecificNodeApplication
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization

  EXTERNAL_LIST = %w[
    none
    nat
    napt
    through
    direct
  ].freeze

  attribute :node_id, :integer
  attribute :user_id, :integer

  attribute :action, :string
  attribute :reason, :string
  attribute :rule_set, :integer
  attribute :rule_list, :string

  attribute :external, :string

  attribute :register_dns, :boolean
  attribute :fqdn, :string

  attribute :note, :string

  validates :node_id, presence: true
  validates :user_id, presence: true
  validates :action, presence: true

  validates :reason, presence: true, if: -> { action != "release" }
  validates :rule_set, presence: true, if: -> { action != "release" }
  validates :rule_list, presence: true, if: -> { rule_set == -1 }
  validates :external, presence: true, if: -> { action != "release" }
  validates :register_dns, inclusion: {in: [true, false]}, if: -> { action != "release" }
  validates :fqdn, presence: true, if: -> { register_dns }
end
