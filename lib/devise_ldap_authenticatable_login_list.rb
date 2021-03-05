# frozen_string_literal: true

# devise_ldap_authenticatable_login_list.rb v0.1 2021-03-05

require 'devise'
require 'devise_ldap_authenticatable'

module Devise
  module LDAP
    class Connection
      def login_list
        @login_list ||= begin
          list = []
          DeviseLdapAuthenticatable::Logger.send(
            "LDAP search all user for #{@attribute}"
          )
          filter = Net::LDAP::Filter.pres(@attribute.to_s)
          @ldap.search(filter: filter) do |entry|
            list << entry[@attribute].first
          end
          op_result = @ldap.get_operation_result
          if op_result.code != 0
            DeviseLdapAuthenticatable::Logger.send(
              "LDAP Error #{op_result.code}: #{op_result.message}"
            )
          end
          DeviseLdapAuthenticatable::Logger.send(
            "LDAP search #{list.size} users"
          )
          list
        end
      end
    end

    module Adapter
      def self.get_login_list
        self.ldap_connect(nil).login_list
      end
    end
  end
end
