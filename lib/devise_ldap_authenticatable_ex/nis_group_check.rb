# devise_ldap_authenticatable_ex/nis_group_check.rb v1.1.0 2025-11-20

# RFC 2307 LDAP as a NIS
# setting: config.ldap_nis_group_check

require "devise"
require "devise_ldap_authenticatable"

module DeviseLdapAuthenticatableEx
  module NisGroupCheck
    def self.load
      create_devise_mattr
      create_devise_ldap_const
      create_devise_ldap_connection_mattr
      create_devise_ldap_connection_instance_methods

      refine_devise_ldap_connection_in_group
    end

    def self.create_devise_mattr
      Devise.mattr_accessor :ldap_nis_group_check
      # rubocop:disable Style/ClassVars
      Devise.class_variable_set(:@@ldap_nis_group_check, false)
      # rubocop:enable Style/ClassVars
    end

    def self.create_devise_ldap_const
      Devise::LDAP.const_set(:DEFAULT_NIS_USERNAME_KEY, "uid")
      Devise::LDAP.const_set(:DEFAULT_NIS_UID_KEY, "uidNumber")
      Devise::LDAP.const_set(:DEFAULT_NIS_GROUP_NAME_KEY, "cn")
      Devise::LDAP.const_set(:DEFAULT_NIS_GID_KEY, "gidNumber")
      Devise::LDAP.const_set(:DEFAULT_NIS_USER_LIST_KEY, "memberUid")
    end

    def self.create_devise_ldap_connection_mattr
      Devise::LDAP::Connection.cattr_reader :nis_groups
      # rubocop:disable Style/ClassVars
      Devise::LDAP::Connection.class_variable_set(:@@nis_groups, {})
      # rubocop:enable Style/ClassVars
    end

    def self.create_devise_ldap_connection_instance_methods
      create_devise_ldap_connection_search_for_nis_group
      create_devise_ldap_connection_nis_gid
      create_devise_ldap_connection_nis_username
      create_devise_ldap_connection_in_group_nis
    end

    def self.create_devise_ldap_connection_search_for_nis_group
      Devise::LDAP::Connection.class_eval do
        def search_for_nis_group(group_name, ldap: @ldap)
          group_attribute = Devise::LDAP::DEFAULT_NIS_GROUP_NAME_KEY
          DeviseLdapAuthenticatable::Logger.send("LDAP search for nis group: #{group_attribute}=#{group_name}")
          filter = Net::LDAP::Filter.eq(group_attribute, group_name)
          ldap_entry = nil
          match_count = 0
          ldap.search(base: @group_base, filter: filter) do |entry|
            ldap_entry = entry
            match_count += 1
          end
          op_result = ldap.get_operation_result
          if op_result.code != 0
            DeviseLdapAuthenticatable::Logger.send("LDAP Error #{op_result.code}: #{op_result.message}")
          end
          DeviseLdapAuthenticatable::Logger.send("LDAP search yielded #{match_count} matches")
          ldap_entry
        end
      end
    end

    def self.create_devise_ldap_connection_nis_gid
      Devise::LDAP::Connection.class_eval do
        def nis_gid
          @nis_gid ||= ldap_param_value(Devise::LDAP::DEFAULT_NIS_GID_KEY)&.first&.to_i
        end
      end
    end

    def self.create_devise_ldap_connection_nis_username
      Devise::LDAP::Connection.class_eval do
        def nis_username
          @nis_username ||= ldap_param_value(Devise::LDAP::DEFAULT_NIS_USERNAME_KEY)&.first
        end
      end
    end

    def self.create_devise_ldap_connection_in_group_nis
      Devise::LDAP::Connection.class_eval do
        def in_group_nis?(group_name)
          in_group = false

          group_checking_ldap =
            if @check_group_membership_without_admin
              @ldap
            else
              Devise::LDAP::Connection.admin
            end

          group_entry = search_for_nis_group(group_name, ldap: group_checking_ldap)
          if group_entry.nil?
            DeviseLdapAuthenticatable::Logger.send("Not found group: #{group_name}")
          elsif group_entry.first(Devise::LDAP::DEFAULT_NIS_GID_KEY).to_i == nis_gid
            DeviseLdapAuthenticatable::Logger.send("User #{dn} IS included in nis primary group: #{group_name}")
            in_group = true
          elsif group_entry[Devise::LDAP::DEFAULT_NIS_USER_LIST_KEY].include?(nis_username)
            DeviseLdapAuthenticatable::Logger.send("User #{dn} IS included in nis group: #{group_name}")
            in_group = true
          end

          unless in_group
            DeviseLdapAuthenticatable::Logger.send("User #{dn} is not in nis group: #{group_name}")
          end
          in_group
        end
      end
    end

    def self.refine_devise_ldap_connection_in_group
      unless Devise::LDAP::Connection.method_defined?(:_in_group?)
        Devise::LDAP::Connection.alias_method :_in_group?, :in_group?
      end

      Devise::LDAP::Connection.class_eval do
        # overwrite in_group?
        def in_group?(group_name,
          group_attribute = Devise::LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
          if Devise.ldap_nis_group_check
            in_group_nis?(group_name)
          else
            _in_group?(group_name, group_attribute)
          end
        end
      end
    end
  end
end
