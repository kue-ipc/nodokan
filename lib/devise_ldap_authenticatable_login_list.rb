# frozen_string_literal: true

# devise_ldap_authenticatable_login_list.rb v0.2 2021-05-06

require 'devise'
require 'devise_ldap_authenticatable'
require 'devise_ldap_authenticatable_authorizable'

module Devise
  module LDAP
    class Connection
      def login_list(with_groups: false)
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

          if with_groups
            list = list.map do |login|
              groups = Adapter.get_group_list(login)
              if groups
                [login, groups]
              else
                nil
              end
            end.compact.to_h
          else
            list.keep_if { |login| Adapter.authorizable?(login) }
          end

          list
        end
      end
    end

    module Adapter
      def self.get_login_list(with_groups: false)
        self.ldap_connect(nil).login_list(with_groups: with_groups)
      end

      def self.get_group_list(login)
        connect = self.ldap_connect(login)
        connect.authorizable? && connect.in_groups
      end
    end
  end
end
