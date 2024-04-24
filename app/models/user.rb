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

  after_save :allocate_network

  after_commit :radius_user

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(username email fullname role deleted nodes_count)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  # rubocop: enable Lint/UnusedMethodArgument

  def allocate_network
    return true if @allocate_network_config.blank?

    logger.debug(
      "User #{username} is allocate: #{@allocate_network_config.to_json}")

    self.auth_network =
      if @allocate_network_config[:auth_network] == "free"
        Network.next_free
      else
        Network.find_identifier(@allocate_network_config[:auth_network])
      end

    if auth_network
      logger.debug "User #{username} is allocated auth network: #{auth_network}"
    end

    @allocate_network_config[:networks]&.each do |net|
      network =
        if net == "auth"
          auth_network
        else
          Network.find_identifier(net)
        end
      add_use_network(network) if network
    end

    self.limit = @allocate_network_config[:limit]
  end

  def ldap_before_save
    sync_ldap!

    if Settings.admin.username == username
      # Set admin, and not allocate networks.
      admin!
    elsif Settings.user_networks.present?
      Settings.user_networks.each do |net_config|
        next unless ldap_groups.include?(net_config[:group])

        @allocate_network_config = {
          auth_network: net_config[:auth_network],
          networks: net_config[:networks],
          limit: net_config[:limit],
        }
        break
      end
    end
  end

  def ldap_entry
    @ldap_entry ||= Devise::LDAP::Adapter.get_ldap_entry(username)
  end

  def ldap_groups
    @ldap_groups ||= Devise::LDAP::Adapter.get_group_list(username)
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

  def to_s
    name
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
      @auth_network = auth_networks&.first
      @auth_network_acquired = true
    end

    @auth_network
  end

  def auth_network=(network)
    if network
      unless network&.auth
        errors.add(:auth_network, "は認証ネットワークではありません。")
        return
      end

      auth_assignments.where.not(network_id: network.id)
        .find_each do |assignment|
        assignment.update(auth: false)
      end

      @auth_network = network
      assignment = assignments.find_or_initialize_by(network: network)
      assignment.update(auth: true)
    else
      auth_assignments.find_each do |assignment|
        assignment.update(auth: false)
      end
    end

    @auth_network_acquired = true
    @auth_network = network
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
    if !destroyed? && !deleted? && auth_network
      RadiusUserAddJob.perform_later(username, auth_network.vlan)
    else
      RadiusUserDelJob.perform_later(username)
    end
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
  end
end
