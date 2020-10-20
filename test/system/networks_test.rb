require 'application_system_test_case'

class NetworksTest < ApplicationSystemTestCase
  # setup do
  #   @network = networks(:one)
  # end

  # test "visiting the index" do
  #   visit networks_url
  #   assert_selector "h1", text: "Networks"
  # end

  # test "creating a Network" do
  #   visit networks_url
  #   click_on "New Network"

  #   check "Auth" if @network.auth
  #   check "Closed" if @network.closed
  #   check "Dhcp" if @network.dhcp
  #   fill_in "Ip6 address", with: @network.ip6_address
  #   fill_in "Ip6 gateway", with: @network.ip6_gateway
  #   fill_in "Ip6 prefix", with: @network.ip6_prefix
  #   fill_in "Ip address", with: @network.ip_address
  #   fill_in "Ip gateway", with: @network.ip_gateway
  #   fill_in "Ip mask", with: @network.ip_mask
  #   fill_in "Name", with: @network.name
  #   fill_in "Vlan", with: @network.vlan
  #   click_on "Create Network"

  #   assert_text "Network was successfully created"
  #   click_on "Back"
  # end

  # test "updating a Network" do
  #   visit networks_url
  #   click_on "Edit", match: :first

  #   check "Auth" if @network.auth
  #   check "Closed" if @network.closed
  #   check "Dhcp" if @network.dhcp
  #   fill_in "Ip6 address", with: @network.ip6_address
  #   fill_in "Ip6 gateway", with: @network.ip6_gateway
  #   fill_in "Ip6 prefix", with: @network.ip6_prefix
  #   fill_in "Ip address", with: @network.ip_address
  #   fill_in "Ip gateway", with: @network.ip_gateway
  #   fill_in "Ip mask", with: @network.ip_mask
  #   fill_in "Name", with: @network.name
  #   fill_in "Vlan", with: @network.vlan
  #   click_on "Update Network"

  #   assert_text "Network was successfully updated"
  #   click_on "Back"
  # end

  # test "destroying a Network" do
  #   visit networks_url
  #   page.accept_confirm do
  #     click_on "Destroy", match: :first
  #   end

  #   assert_text "Network was successfully destroyed"
  # end
end
