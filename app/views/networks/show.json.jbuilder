json.partial! 'networks/network', network: @network
json.selectable current_user.admin? || current_user.networks.include?(@network)
json.managable current_user.admin?
