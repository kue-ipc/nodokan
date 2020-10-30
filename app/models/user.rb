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
  }

  has_many :nodes, dependent: :nullify

  has_many :network_users, dependent: :destroy
  has_many :available_network_users,
    -> { where(available: true) }, class_name: 'NetworkUser'
  has_many :managable_network_users,
    -> { where(managable: true) }, class_name: 'NetworkUser'
  has_many :assigned_network_users,
    -> { where(assigned: true) }, class_name: 'NetworkUser'

  has_many :networks, through: :network_users
  has_many :available_networks, through: :available_network_users,
                                source: :network
  has_many :managable_networks, through: :managable_network_users,
                                source: :network
  has_many :assigned_networks, through: :assigned_network_users,
                               source: :network

  validates :username, presence: true,
                       uniqueness: {case_sensitive: true},
                       length: {maximum: 255}
  validates :email, presence: true, uniqueness: {case_sensitive: true},
                    length: {maximum: 255}
  validates :fullname, allow_blank: true, length: {maximum: 255}

  def ldap_before_save
    sync_ldap!
    # The first user is the admin.
    admin! if User.count.zero?
  end

  def ldap_entry
    return if deleted

    @ldap_entry ||= Devise::LDAP::Adapter.get_ldap_entry(username)
  end

  def ldap_mail
    ldap_entry&.[]('mail')&.first
  end

  def ldap_display_name
    ldap_entry&.[]("displayName;lang-#{I18n.default_locale}")&.first ||
      ldap_entry&.[]('displayName')&.first
  end

  def sync_ldap!
    if deleted
      errors.add(:deleted, 'のため、LDAP同期はできません。')
      return
    end

    unless ldap_entry
      errors.add(:username, 'はLDAP上にないため、同期できません。')
      return
    end

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
end
