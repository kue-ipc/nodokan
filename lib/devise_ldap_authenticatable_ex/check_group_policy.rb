# devise_ldap_authenticatable_ex/check_group_policy.rb v1.0.1 2024-04-16

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
      create_devise_mattr
      create_devise_ldap_connection_instance_methods
      refine_devise_ldap_connection_in_required_groups
    end

    def self.create_devise_mattr
      Devise.mattr_accessor :ldap_check_group_policy
      # rubocop: disable Style/ClassVars
      Devise.class_variable_set(:@@ldap_check_group_policy, :and)
      # rubocop: enable Style/ClassVars
    end

    def self.create_devise_ldap_connection_instance_methods
      Devise::LDAP::Connection.attr_reader :in_groups

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
      end
    end

    # rubocop: disable Metrics/MethodLength
    def self.refine_devise_ldap_connection_in_required_groups
      unless Devise::LDAP::Connection.method_defined?(:in_required_groups_and?)
        Devise::LDAP::Connection.alias_method :in_required_groups_and?,
          :in_required_groups?
      end

      Devise::LDAP::Connection.class_eval do
        # overwrite in_required_groups?
        def in_required_groups?
          return true unless @check_group_membership ||
            @check_group_membership_without_admin

          case Devise.ldap_check_group_policy
          when :and, /\Aand\z/i, "&", "&&"
            if in_required_groups_and?
              @in_groups = @required_groups.map do |group|
                if group.is_a?(Array)
                  group[1]
                else
                  group
                end
              end
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
    # rubocop: enable Metrics/MethodLength
  end
end
