# Nic regist auth


# User-Name = "hhhhhhhhhh"
# User-Password
# Cleartext-Password:




# class NicRegistAuthJob < ApplicationJob
#   queue_as :default

#   def perform(nic)
#     mac_address = nic.mac_address(char_case: :lower, sep: '')
#     password = Settings.config.radius_mac_password || mac_address

#     radcheck = Radius::Radcheck.find_or_initialize_by(username: mac_address)
#     radcheck.attrbute =

#   end
# end
