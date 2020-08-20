class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable, :rememberable, :validatable
  devise :ldap_authenticatable

  enum role: {
    user: 0,
    admin: 1,
    guest: 2,
    remnant: 3,
  }

  has_many :nodes, dependent: :nullify

  has_many :subnetwork_users, dependent: :destroy
  has_many :assignable_subnetwork_users, -> { where(assignable: true) }, class_name: 'SubnetworkUser'
  has_many :managable_subnetwork_users, -> { where(managable: true) }, class_name: 'SubnetworkUser'

  has_many :subnetworks, through: :subnetwork_users
  has_many :assignable_subnetworks, through: :assignable_subnetwork_users, source: :subnetwork
  has_many :managable_subnetworks, through: :managable_subnetwork_users, source: :subnetwork

  def ldap_before_save
    sync_ldap!
    # The first user is the admin.
    admin! if User.count.zero?
  end

  def ldap_entry
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
    if ldap_entry
      user! if remnant?
      self.email = ldap_mail
      self.fullname = ldap_display_name
    else
      remnant!
    end
  end
end
