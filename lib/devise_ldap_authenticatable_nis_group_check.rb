# frozen_string_literal: true

# devise_ldap_authenticatable_nis_group_check.rb v0.1.3 2021-06-11

# RFC 2307 LDAP as a NIS
# setting: config.ldap_nis_group_check

require "devise"
require "devise_ldap_authenticatable"

module Devise
  # rubocop:disable Style/ClassVars
  mattr_accessor :ldap_nis_group_check
  mattr_accessor :ldap_nis_group_cache_age
  @@ldap_nis_group_check = false
  @@ldap_nis_group_cache_age = 60 * 60 # 1 hour
  # rubocop:enable Style/ClassVars

  module LDAP
    DEFAULT_GID_NUMBER_KEY = "gidNumber"
    DEFAULT_MEMBER_UID_KEY = "memberUid"
    DEFAULT_UID_KEY = "uid"

    class Connection
      # rubocop:disable Style/ClassVars
      @@nis_groups = {}
      # rubocop:enable Style/ClassVars

      def nis_group(group_name)
        group = @@nis_groups[group_name] || {}
        if group[:expired_time] && Devise.ldap_nis_group_cache_age &&
           group[:expired_time] >= Devise.ldap_nis_group_cache_age
          return group
        end

        group_checking_ldap =
          if @check_group_membership_without_admin
            @ldap
          else
            Connection.admin
          end

        group[:expired_time] = Time.current + Devise.ldap_nis_group_cache_age if Devise.ldap_nis_group_cache_age
        group[:gid_number] = nil
        group[:members] = []

        group_checking_ldap.search(base: group_name, scope: Net::LDAP::SearchScope_BaseObject) do |entry|
          group[:gid_number] = entry[LDAP::DEFAULT_GID_NUMBER_KEY][0].to_i
          group[:members] = entry[LDAP::DEFAULT_MEMBER_UID_KEY]&.to_a || []
        end

        DeviseLdapAuthenticatable::Logger.send("Not entry group: #{group_name}") if group[:gid_number].nil?

        @@nis_groups[group_name] = group
        group
      end

      def gid_number
        @gid_number ||= ldap_param_value(LDAP::DEFAULT_GID_NUMBER_KEY)[0].to_i
      end

      def uid
        @uid ||= ldap_param_value(LDAP::DEFAULT_UID_KEY)[0]
      end

      def in_group_nis?(group_name)
        in_group = false

        group = nis_group(group_name)

        if group[:gid_number].nil?
          DeviseLdapAuthenticatable::Logger.send("Not found group: #{group_name}")
          return false
        end

        if group[:gid_number] == gid_number
          in_group = true
          DeviseLdapAuthenticatable::Logger.send("User #{dn} is included in nis primary group: #{group_name}")
        elsif group[:members].include?(uid)
          in_group = true
          DeviseLdapAuthenticatable::Logger.send("User #{dn} is included in nis group: #{group_name}")
        end

        # DeviseLdapAuthenticatable::Logger.send("User #{dn} is not in nis group: #{group_name}") unless in_group

        in_group
      end

      # overwrite in_group?
      alias _in_group? in_group?

      def in_group?(group_name, group_attribute = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
        if ::Devise.ldap_nis_group_check
          in_group_nis?(group_name)
        else
          _in_group?(group_name, group_attribute)
        end
      end
    end
  end
end
