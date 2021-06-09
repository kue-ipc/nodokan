class User < ApplicationRecord
  # Include default devise modules.
  # :database_authenticatable or :ldap_authenticatable
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable, :rememberable, :validatable
  devise :ldap_authenticatable

  enum role: {
    user: 0,
    admin: 1,
    guest: 2,
  }

  has_many :nodes, dependent: :nullify

  has_many :assignments, dependent: :destroy
  has_many :auth_assignments,
    -> { where(auth: true) },
    class_name: 'Assignment', inverse_of: :user
  has_many :use_assignments,
    -> { where(use: true) },
    class_name: 'Assignment', inverse_of: :user
  has_many :manage_assignments,
    -> { where(manage: true) },
    class_name: 'Assignment', inverse_of: :user

  has_many :networks, through: :assignments
  has_many :auth_networks, through: :auth_assignments, source: :network
  has_many :use_networks, through: :use_assignments, source: :network
  has_many :manage_networks, through: :manage_assignments, source: :network

  validates :username, presence: true,
                       uniqueness: { case_sensitive: true },
                       length: { maximum: 255 }
  validates :email, presence: true,
                    length: { maximum: 255 }
  validates :fullname, allow_blank: true, length: { maximum: 255 }

  after_save :allocate_network

  after_commit :radius_user

  def allocate_network
    return true if @allocate_network_config.blank?

    logger.debug "User #{username} is allocate: #{@allocate_network_config.to_json}"

    self.auth_network =
      if @allocate_network_config[:auth_network] == 'free'
        Network.next_free
      else
        Network.find_identifier(@allocate_network_config[:auth_network])
      end

    logger.debug "User #{username} is allocated auth network: #{auth_network}" if auth_network

    @allocate_network_config[:networks]&.each do |net|
      network =
        if net == 'auth'
          auth_network
        else
          Network.find_identifier(net)
        end
      add_use_network(network) if network
    end
  end

  def ldap_before_save
    sync_ldap!

    if User.count.zero?
      # The first user is the admin, not allocate networks.
      admin!
    elsif Settings.user_networks.present?
      Settings.user_networks.each do |net_config|
        next unless ldap_groups.include?(net_config[:group])

        @allocate_network_config = {
          auth_network: net_config[:auth_network],
          networks: net_config[:networks],
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
    ldap_entry&.[]('mail')&.first
  end

  def ldap_display_name
    ldap_entry&.[]("displayName;lang-#{I18n.default_locale}")&.first ||
      ldap_entry&.[]('displayName')&.first
  end

  def sync_ldap!
    unless ldap_entry
      errors.add(:username, 'はLDAP上にないため、同期できません。')
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
        "#{fullname} (#{username})"
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

  def selectable_networks
    @selectable_networks ||=
      if admin?
        Network.all
      else
        use_networks
      end
  end

  def auth_network
    @auth_network ||= auth_networks&.first
  end

  def auth_network=(network)
    if network.nil?
      auth_assignments.each do |assignment|
        assignment.auth = false
        assignment.destroy unless assignment.assigned?
      end
      return
    end

    unless network&.auth
      errors.add(:auth_network, 'は認証ネットワークではありません。')
      return
    end

    auth_assignments.each do |assignment|
      assignment.auth = false
      assignment.destroy unless assignment.assigned?
    end

    @auth_network = network
    assignment = assignments.find_or_initialize_by(network: network)
    assignment.auth = true
    assignment.save
  end

  def add_use_network(network)
    assignment = assignments.find_or_initialize_by(network: network)
    assignment.use = true
    assignment.save
  end

  def remove_use_network(network)
    assignment = use_assignments.find_by(network: network)
    return if assignment.nil?

    assignment.use = false
    assignment.destroy unless assignment.assigned?
  end

  def clear_use_networks
    use_assignments.each do |assignment|
      assignment.use = false
      assignment.destroy unless assignment.assigned?
    end
  end

  def radius_user
    if !destroyed? && !deleted? && auth_network
      RadiusUserAddJob.perform_later(username, auth_network.vlan)
    else
      RadiusUserDelJob.perform_later(username)
    end
  end
end
