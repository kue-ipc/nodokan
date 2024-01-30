require "devise_ldap_authenticatable_ex/authorizable"
require "devise_ldap_authenticatable_ex/check_group_policy"
require "devise_ldap_authenticatable_ex/login_list"
require "devise_ldap_authenticatable_ex/nis_group_check"

module DeviseLdapAuthenticatableEx
  def self.load
    DeviseLdapAuthenticatableEx::Authorizable.load
    DeviseLdapAuthenticatableEx::CheckGroupPolicy.load
    DeviseLdapAuthenticatableEx::LoginList.load
    DeviseLdapAuthenticatableEx::NisGroupCheck.load
  end
end
