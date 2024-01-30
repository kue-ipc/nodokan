# devise_ldap_authenticatable_ex/authorizable.rb v1.0.0 2024-01-30

# `authorizable?` is `authorized?` without `authenticated?`

require "devise"
require "devise_ldap_authenticatable"

module DeviseLdapAuthenticatableEx
  module Authorizable
    def self.load
      Devise::LDAP::Adapter.module_eval do
        def self.authorizable?(login)
          ldap_connect(login).authorizable?
        end
      end

      Devise::LDAP::Connection.class_eval do
        def authorizable?
          !search_for_login.nil? &&
            in_required_groups? &&
            has_required_attribute? &&
            has_required_attribute_presence?
        end
      end
    end
  end
end
