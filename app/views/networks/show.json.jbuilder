json.partial! "networks/network", network: @network
json.current_user do
  json.auth @network.auth_for?(current_user)
  json.usable @network.usable_for?(current_user)
  json.default @network.default_for?(current_user)
  json.manageable @network.manageable_for?(current_user)
end
