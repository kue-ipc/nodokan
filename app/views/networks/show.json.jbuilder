json.partial! 'networks/network', network: @network
json.current_user do
  json.auth @network.auth?(current_user)
  json.usable @network.usable?(current_user)
  json.manageable @network.manageable?(current_user)
end
