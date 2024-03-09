# devise_ldap_authenticatable_ex/check_group_policy.rb v1.0.0 2024-01-30

# check group membersip policy
# setting
# * config.ldap_check_group_policy = :and
#     A user must belongs to any group.
# * config.ldap_check_group_policy = :or
#     A user must belgons to all groups.
# variable
# * @in_groups
#     Groups to which the user belongs with :or policy.

require "devise"
require "devise_ldap_authenticatable"

module DeviseLdapAuthenticatableEx
  module CheckGroupPolicy
    def self.load
      Devise.mattr_accessor :ldap_check_group_policy
      Devise.class_variable_set(:@@ldap_check_group_policy, :and) # rubocop:disable Style/ClassVars

      Devise::LDAP::Connection.attr_reader :in_groups
      unless Devise::LDAP::Connection.instance_methods
        .include?(:in_required_groups_and?)
        Devise::LDAP::Connection.alias_method :in_required_groups_and?,
          :in_required_groups?
      end

      Devise::LDAP::Connection.class_eval do
        def in_required_groups_or?
          return true unless @check_group_membership ||
            @check_group_membership_without_admin

          ## FIXME set errors here, the ldap.yml isn't set properly.
          return false if @required_groups.nil?

          return !@in_groups.empty? if @in_groups

          @in_groups = []
          @required_groups.each do |group|
            if group.is_a?(Array)
              @in_groups << group[1] if in_group?(group[1], group[0])
            elsif in_group?(group)
              @in_groups << group
            end
          end
          !@in_groups.empty?
        end

        # overwrite in_required_groups?
        def in_required_groups?
          return true unless @check_group_membership ||
            @check_group_membership_without_admin

          case Devise.ldap_check_group_policy
          when :and, /\Aand\z/i, "&", "&&"
            if in_required_groups_and?
              @in_groups = @required_groups.map { |group|
                if group.is_a?(Array)
                  group[1]
                else
                  group
                end
              }
              true
            else
              false
            end
          when :or, /\Aor\z/i, "|", "||"
            in_required_groups_or?
          else
            DeviseLdapAuthenticatable::Logger.send(
              "Invalid check policy: #{Devise.ldap_check_group_policy}")
            false
          end
        end
      end
    end
  end
end
