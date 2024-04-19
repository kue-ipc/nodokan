# devise_ldap_authenticatable_ex/login_list.rb v1.0.1 2024-04-16

require "devise"
require "devise_ldap_authenticatable"

module DeviseLdapAuthenticatableEx
  module LoginList
    def self.load
      create_devise_ldap_connection_instance_methods
      create_devise_ldap_adapter_class_methods
    end

    def self.create_devise_ldap_connection_instance_methods
      Devise::LDAP::Connection.class_eval do
        def login_list
          @login_list ||= begin
            list = []
            DeviseLdapAuthenticatable::Logger.send(
              "LDAP search all user for #{@attribute}")
            filter = Net::LDAP::Filter.pres(@attribute.to_s)
            @ldap.search(filter: filter) do |entry|
              list << entry.first(@attribute)
            end

            op_result = @ldap.get_operation_result
            if op_result.code != 0
              DeviseLdapAuthenticatable::Logger.send(
                "LDAP Error #{op_result.code}: #{op_result.message}")
            end
            DeviseLdapAuthenticatable::Logger.send("Found #{list.size} users")

            list
          end
        end
      end
    end

    def self.create_devise_ldap_adapter_class_methods
      Devise::LDAP::Adapter.class_eval do
        # rubocop: disable Naming/AccessorMethodName
        def self.get_login_list
          ldap_connect(nil).login_list
        end
        # rubocop: enable Naming/AccessorMethodName

        def self.get_group_list(login)
          connect = ldap_connect(login)
          if connect.in_required_groups?
            connect.in_groups
          else
            []
          end
        end
      end
    end
  end
end
