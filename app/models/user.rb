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

  has_many :allocations
  has_many :admin_allocations, -> { where(admin: true) },
    class_name: 'Allocation'
  has_many :usable_allocations, -> { where(usable: true) },
    class_name: 'Allocation'
  has_many :auth_allocations, -> { where(auth: true) },
    class_name: 'Allocation'

  has_many :networks, through: :allocations
  has_many :admin_networks, through: :admin_allocations, source: :network
  has_many :usable_networks, through: :usable_allocations, source: :network
  has_many :auth_networks, through: :auth_allocations, source: :network

  validates :username, presence: true,
                       uniqueness: {case_sensitive: true},
                       length: {maximum: 255}
  validates :email, presence: true,
                    length: {maximum: 255}
  validates :fullname, allow_blank: true, length: {maximum: 255}

  after_commit :radius_user

  def allocate_network!(net_config)
    auth_network =
      case net_config[:auth_network]
      when nil
        nil
      when 'free'
        Network.next_free
      when /^v(\d{1-4})$/
        Network.find_by_vlan($1.to_i)
      when /^\#(\d*)$/
        Network.find($1.to_i)
      else
        logger.error "Invalid network config: #{net_config[:auth_network]}"
        nil
      end
    if auth_network
      logger.debug "User #{username} is allocated auth network: #{auth_network}"
    end

    if net_config[:networks]
      net_config[:networks].each do |net|
        networks <<
          case net
          when 'auth'
            auth_network
          when /^v(\d{1-4})$/
            Network.find_by_vlan($1.to_i)
          when /^\#(\d*)$/
            Network.find($1.to_i)
          else
            logger.error "Invalid network config: #{net}"
            nil
          end
      end
    end
  end

  def ldap_before_save
    sync_ldap!

    if User.count.zero?
      # The first user is the admin, not allocate networks.
      admin!
    elsif Settings.user_networks.present?
      Settings.user_networks.each do |net_config|
        if ldap_groups.include?(net_config[:group])
          allocate_network!(net_config)
          break
        end
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

  def radius_user
    if !deleted? && auth_network&.auth
      RadiusRegisterUserJob.perform_later(username, auth_network.vlan)
    else
      RadiusUnregisterUserJob.perform_later(username)
    end
  end

  def selectable_networks
    @selectable_networks ||=
      if admin?
        Network.all
      else
        usable_networks
      end
  end

  def auth_network
    auth_networks&.first
  end

  def auth_network=(network)
    auth_networks = network
  end
end
