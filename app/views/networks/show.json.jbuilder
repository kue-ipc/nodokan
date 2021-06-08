json.partial! 'networks/network', network: @network
json.auth @network.auth_users.exists?(current_user.id)
json.selectable current_user.admin? || @network.use_users.exists?(current_user.id)
json.managable current_user.admin? || @network.manage_users.exists?(current_user.id)
