# devise_ldap_authenticatable_ex/nis_group_check.rb v1.0.0 2024-01-30

# RFC 2307 LDAP as a NIS
# setting: config.ldap_nis_group_check

require "devise"
require "devise_ldap_authenticatable"

module DeviseLdapAuthenticatableEx
  module NisGroupCheck
    def self.load
      Devise.mattr_accessor :ldap_nis_group_check
      Devise.mattr_accessor :ldap_nis_group_cache_age
      # rubocop:disable Style/ClassVars
      Devise.class_variable_set(:@@ldap_nis_group_check, false)
      Devise.class_variable_set(:@@ldap_nis_group_cache_age, 60 * 60) # 1 hour
      # rubocop:enable Style/ClassVars

      Devise::LDAP.const_set(:DEFAULT_GID_NUMBER_KEY, "gidNumber")
      Devise::LDAP.const_set(:DEFAULT_MEMBER_UID_KEY, "memberUid")
      Devise::LDAP.const_set(:DEFAULT_UID_KEY, "uid")

      Devise::LDAP::Connection.cattr_reader :nis_groups
      Devise::LDAP::Connection.class_variable_set(:@@nis_groups, {}) # rubocop:disable Style/ClassVars
      unless Devise::LDAP::Connection.instance_methods.include?(:_in_group?)
        Devise::LDAP::Connection.alias_method :_in_group?, :in_group?
      end

      Devise::LDAP::Connection.class_eval do
        def nis_group(group_name)
          group = Devise::LDAP::Connection.nis_groups[group_name] || {}
          if group[:expired_time] && Devise.ldap_nis_group_cache_age &&
              group[:expired_time] >= Devise.ldap_nis_group_cache_age
            return group
          end

          group_checking_ldap =
            if @check_group_membership_without_admin
              @ldap
            else
              Devise::LDAP::Connection.admin
            end

          if Devise.ldap_nis_group_cache_age
            group[:expired_time] = Time.current +
              Devise.ldap_nis_group_cache_age
          end
          group[:gid_number] = nil
          group[:members] = []

          group_checking_ldap.search(base: group_name,
            scope: Net::LDAP::SearchScope_BaseObject) do |entry|
            group[:gid_number] =
              entry[Devise::LDAP::DEFAULT_GID_NUMBER_KEY][0].to_i
            group[:members] =
              entry[Devise::LDAP::DEFAULT_MEMBER_UID_KEY]&.to_a || []
          end

          if group[:gid_number].nil?
            DeviseLdapAuthenticatable::Logger.send(
              "Not entry group: #{group_name}")
          end

          Devise::LDAP::Connection.nis_groups[group_name] = group
          group
        end

        def gid_number
          @gid_number ||= ldap_param_value(Devise::LDAP::DEFAULT_GID_NUMBER_KEY)[0].to_i
        end

        def uid
          @uid ||= ldap_param_value(Devise::LDAP::DEFAULT_UID_KEY)[0]
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
