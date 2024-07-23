class User < ApplicationRecord
  FLAGS = {
    deleted: "d",
  }.freeze

  # Include default devise modules.
  # :database_authenticatable or :ldap_authenticatable
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable, :rememberable, :validatable
  devise :ldap_authenticatable, :lockable, :rememberable

  enum :role, {
    user: 0,
    admin: 1,
    guest: 2,
  }, validate: true

  has_many :nodes, dependent: :restrict_with_error

  has_many :assignments, dependent: :destroy
  has_many :auth_assignments, -> { where(auth: true) },
    class_name: "Assignment", inverse_of: :user
  has_many :use_assignments, -> { where(use: true) },
    class_name: "Assignment", inverse_of: :user
  has_many :manage_assignments, -> { where(manage: true) },
    class_name: "Assignment", inverse_of: :user

  has_many :networks, through: :assignments
  has_many :auth_networks, through: :auth_assignments, source: :network
  has_many :use_networks, through: :use_assignments, source: :network
  has_many :manage_networks, through: :manage_assignments, source: :network

  validates :username, presence: true,
    uniqueness: {case_sensitive: true},
    length: {maximum: 255}
  validates :email, presence: true,
    length: {maximum: 255}
  validates :fullname, allow_blank: true, length: {maximum: 255}
  validates :limit, allow_nil: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}

  validates_each :auth_network do |record, attr, value|
    if value && !value.auth
      record.errors.add(attr, I18n.t("errors.messages.not_auth_network"))
    end
  end

  after_save :allocate_network
  after_save :save_auth_network!

  after_commit :radius_user

  # class methods

  def self.find_identifier(str)
    find_by(username: str)
  end

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(username email fullname role deleted nodes_count)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  # rubocop: enable Lint/UnusedMethodArgument

  def allocate_network
    return if @allocate_network_config.blank?

    if Settings.feature.user_auth_network &&
        @allocate_network_config[:auth_network]
      network = find_network(@allocate_network_config[:auth_network])
      unless network
        errors.add(:auth_network, I18n.t("errors.messages.no_allocate"))
        throw :abort
      end

      self.auth_network = network
      # assgimentを作成しておくために、セーブしておく
      save_auth_network!
    end

    @allocate_network_config[:networks]&.each do |net|
      network = find_network(net)
      unless network
        errors.add(:use_networks, I18n.t("errors.messages.no_allocate"))
        throw :abort
      end

      add_use_network(network) || throw(:abort)
    end
  end

  private def find_network(net)
    case net
    when "free"
      Network.next_free_auth
    when "auth"
      auth_network
    else
      Network.find_identifier(net)
    end
  end

  # auto call this function before creat user by devise and user_sync
  def ldap_before_save
    sync_ldap!

    if Settings.admin.username == username
      # Set admin, and not allocate networks.
      admin!
      return
    end

    config = {
      auth_network: nil,
      networks: [],
      limit: nil,
      role: "user",
    }
    config.merge!(
      Settings.user_default_config || {},
      Settings.user_initial_configs
        &.find { |conf| ldap_groups.include?(conf[:group]) } || {})

    @allocate_network_config = config.slice(:auth_network, :networks)
    self.limit = config[:limit]
    self.role = config[:role]
  end

  # TODO: devise_ldap_authenticatableのをそのまま使うのに変更予定
  def ldap_entry
    @ldap_entry ||= Devise::LDAP::Adapter.get_ldap_entry(username)
  end

  # TODO: devise_ldap_authenticatableのをそのまま使うのに変更予定
  def ldap_groups
    @ldap_groups ||=
      Devise::LDAP::Adapter.get_group_list(username).map do |name|
        name.split(",").first.split("=").second
      end
  end

  def ldap_mail
    ldap_entry&.[]("mail")&.first
  end

  def ldap_display_name
    ldap_entry&.[]("displayName;lang-#{I18n.default_locale}")&.first ||
      ldap_entry&.[]("displayName")&.first
  end

  def sync_ldap!
    unless ldap_entry
      errors.add(:username, "はLDAP上にないため、同期できません。")
      return
    end

    self.deleted = false
    self.email = ldap_mail
    self.fullname = ldap_display_name

    ldap_entry
  end

  def name
    @name ||=
      if fullname.present?
        "#{username} (#{fullname})"
      else
        username
      end
  end

  def deleted?
    deleted
  end

  def authorizable?
    Devise::LDAP::Adapter.authorizable?(username)
  end

  def auth_network_id
    auth_network&.id
  end

  def auth_network_id=(id)
    self.auth_network = id.presence && Network.find(id)
  end

  def auth_network
    unless @auth_network_acquired
      @auth_network = auth_networks.first
      @auth_network_acquired = true
    end

    @auth_network
  end

  def auth_network=(network)
    if network && !network.is_a?(Network)
      raise ActiveRecord::AssociationTypeMismatch,
        "Network expected, " \
        "got #{network.inspect} which is an instance of #{network.class}"
    end

    # no change
    return if network == auth_network

    @auth_network_change ||= [auth_network, nil]
    @auth_network_change[1] = network
    @auth_network_acquired = true
    @auth_network = network
  end

  def save_auth_network!
    return true unless auth_network_changed?

    Assignment.transaction do
      if auth_network
        auth_assignments.where.not(network: auth_network)
          .find_each do |assignment|
          assignment.update!(auth: false)
        end

        assignment = assignments.find_or_initialize_by(network: auth_network)
        assignment.update!(auth: true)
      else
        auth_assignments.find_each do |assignment|
          assignment.update!(auth: false)
        end
      end
    end

    @auth_network_previous_change = auth_network_change
    clear_auth_network_change
    true
  end

  def save_auth_network
    save_auth_network!
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    false
  end

  attr_reader :auth_network_change, :auth_network_previous_change

  def auth_network_changed?
    auth_network_change.present?
  end

  def auth_network_previously_changed?
    auth_network_previous_change.present?
  end

  def auth_network_previously_was
    auth_network_previous_change&.first
  end

  def auth_network_was
    auth_network_change&.first
  end

  def auth_network_will_change!
    return if auth_network_changed?

    @auth_network_change = [auth_network, auth_network]
  end

  def clear_auth_network_change
    @auth_network_change = nil
  end

  def restore_auth_network!
    return unless auth_network_changed?

    @auth_network = auth_network_was
    clear_auth_network_change
  end

  def add_use_network(network, manage: false)
    assignment = assignments.find_or_initialize_by(network: network)
    assignment.update(use: true, manage: manage)
  end

  def remove_use_network(network)
    assignment = assignments.find_by(network: network)
    return if assignment.nil?

    assignment.update(use: false, manage: false)
  end

  def clear_use_networks
    assignments.each do |assignment|
      assignment.update(use: false, manage: false)
    end
  end

  def usable_networks
    @usable_networks ||=
      if admin?
        Network.readonly
      else
        use_networks
      end
  end

  def manageable_networks
    @manageable_networks ||=
      if admin?
        Network.readonly
      else
        manage_networks
      end
  end

  def radius_user
    return unless Settings.feature.user_auth_network

    if destroyed?
      if !deleted? && auth_network.present?
        RadiusUserDelJob.perform_later(username)
      end
    elsif deleted_previously_changed? || auth_network_previously_changed?
      if !deleted? && auth_network.present?
        RadiusUserAddJob.perform_later(username, auth_network.vlan)
      else
        RadiusUserDelJob.perform_later(username)
      end
    end
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
  end

  def unlimited
    limit.nil?
  end

  def node_creatable?
    return true if admin?

    return false if limit && limit <= nodes_count
    return false if Settings.config.node_require_nic &&
      Settings.config.nic_require_network &&
      use_networks.count.zero?

    true
  end

  def identifier
    username
  end
end
