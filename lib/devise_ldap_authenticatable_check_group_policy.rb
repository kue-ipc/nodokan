# frozen_string_literal: true

# check group membersip policy
# setting
# * config.ldap_check_group_policy = :and
#     A user must belongs to any group.
# * config.ldap_check_group_policy = :or
#     A user must belgons to all groups.

require 'devise'
require 'devise_ldap_authenticatable'

module Devise
  mattr_accessor :ldap_check_group_policy
  @@ldap_check_group_policy = :and

  module LDAP
    class Connection
      def in_required_groups_or?
        return true unless @check_group_membership ||
                           @check_group_membership_without_admin

        ## FIXME set errors here, the ldap.yml isn't set properly.
        return false if @required_groups.nil?

        @required_groups.each do |group|
          if group.is_a?(Array)
            return true if in_group?(group[1], group[0])
          else
            return true if in_group?(group)
          end
        end
        false
      end

      # overwrite in_required_groups?
      alias in_required_groups_and? in_required_groups?
      def in_required_groups?
        return true unless @check_group_membership ||
                           @check_group_membership_without_admin

        case Devise.ldap_check_group_policy
        when :and, /\Aand\z/i, '&', '&&'
          in_required_groups_and?
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
