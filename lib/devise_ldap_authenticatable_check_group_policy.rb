# frozen_string_literal: true

# devise_ldap_authenticatable_check_group_policy.rb v0.2 2021-05-06

# check group membersip policy
# setting
# * config.ldap_check_group_policy = :and
#     A user must belongs to any group.
# * config.ldap_check_group_policy = :or
#     A user must belgons to all groups.
# variable
# * @in_groups
#     Groups to which the user belongs with :or policy.

require 'devise'
require 'devise_ldap_authenticatable'

module Devise
  mattr_accessor :ldap_check_group_policy
  @@ldap_check_group_policy = :and

  module LDAP
    class Connection
      attr_reader :in_groups

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
          else
            @in_groups << group if in_group?(group)
          end
        end
        !@in_groups.empty?
      end

      # overwrite in_required_groups?
      alias in_required_groups_and? in_required_groups?
      def in_required_groups?
        return true unless @check_group_membership ||
                           @check_group_membership_without_admin

        case Devise.ldap_check_group_policy
        when :and, /\Aand\z/i, '&', '&&'
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
        when :or, /\Aor\z/i, '|', '||'
          in_required_groups_or?
        else
          DeviseLdapAuthenticatable::Logger.send(
            "Invalid check policy: #{Devise.ldap_check_group_policy}"
          )
          false
        end
      end
    end
  end
end
