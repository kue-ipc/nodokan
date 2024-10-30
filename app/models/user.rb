class User < ApplicationRecord
  include UniqueIdentifier
  include Flag

  unique_identifier "@", :username

  flag :flag, {
    deleted: "d",
  }

  has_paper_trail

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
    class_name: "Assignment", inverse_of: :user, dependent: nil
  has_many :use_assignments, -> { where(use: true) },
    class_name: "Assignment", inverse_of: :user, dependent: nil

  has_many :networks, through: :assignments
  has_many :auth_networks, through: :auth_assignments, source: :network
  has_many :use_networks, through: :use_assignments, source: :network

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

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w[username email fullname role deleted nodes_count]
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

    @allocate_network_config[:networks]&.each_with_index do |net, idx|
      network = find_network(net)
      unless network
        errors.add(:use_networks, I18n.t("errors.messages.no_allocate"))
        throw :abort
      end

      add_use_network(network, default: idx == 0) || throw(:abort)
    end
  end

  private def find_network(net)
    case net
    when "free"
      Network.next_free_auth
    when "auth"
      auth_network
    else
      begin
        Network.find_identifier(net)
      rescue StandardError => e
        Rails.logger.warn "Not found #{net} network: #{e}"
        nil
      end
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

    initial_configs = Settings.user_initial_configs.select do |conf|
      conf[:group].nil? || conf[:group] == "*" ||
        ldap_groups.include?(conf[:group])
    end.select do |conf|
      conf[:attribute].nil? ||
        conf[:attribute].all? do |k, v|
          if v == "*"
            !ldap_entry.first(k).nil?
          else
            ldap_entry[k].include?(v)
          end
       end
    end

    config = {
      auth_network: nil,
      networks: [],
      limit: nil,
      role: "user",
    }.merge(*initial_configs)

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

  def ldap_attributes
    @ldap_attributes ||= ldap_entry&.to_h
  end

  def ldap_mail
    ldap_entry&.first(Settings.ldap.user.attribute.mail)
  end

  def ldap_display_name
    attr = Settings.ldap.user.attribute.display_name
    locale_attr = "#{attr};lang-#{I18n.default_locale}"
    ldap_entry&.first(locale_attr) || ldap_entry&.first(attr)
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

  def add_use_network(network, params = {})
    add_use_network_id(network.id, params)
  end

  def remove_use_network(network)
    remove_use_network_id(network.id)
  end

  def add_use_network_id(network_id, params = {})
    assignment = assignments.find_or_initialize_by(network_id:)
    assignment.use = true
    assignment.assign_attributes(params)

    result = assignment.save
    if result
      @usable_networks = nil
      @default_network = nil
      @manageable_networks = nil
    end
    result
  end

  def remove_use_network_id(network_id)
    assignment = assignments.find_by(network_id:)
    return if assignment.nil?

    result = assignment.update(use: false)
    if result
      @usable_networks = nil
      @default_network = nil
      @manageable_networks = nil
    end
    result
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

  # NOTE: デフォルトネットワークがない場合は、最初のネットワークになる。
  def default_network
    @default_network ||=
      use_assignments.order(default: :desc, id: :asc).first&.network
  end

  def manageable_networks
    @manageable_networks ||=
      if admin?
        Network.readonly
      else
        usable_networks.select { |network| network.assignment.manage? }
      end
  end

  def usable_network_ids
    usable_networks.map(&:id)
  end

  def default_network_id
    default_network&.id
  end

  def manageable_network_ids
    manageable_networks.map(&:id)
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
end
