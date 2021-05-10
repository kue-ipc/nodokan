# frozen_string_literal: true

# devise_ldap_authenticatable_authorizable.rb v0.1.1 2021-05-06

# `authorizable?` is `authorized?` without `authenticated?`

require 'devise'
require 'devise_ldap_authenticatable'

module Devise
  module LDAP
    module Adapter
      def self.authorizable?(login)
        self.ldap_connect(login).authorizable?
      end
    end

    class Connection
      def authorizable?
        !search_for_login.nil? &&
          in_required_groups? &&
          has_required_attribute? &&
          has_required_attribute_presence?
      end
    end
  end
end
