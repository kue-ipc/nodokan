require "application_system_test_case"

class SubnetworksTest < ApplicationSystemTestCase
  setup do
    @subnetwork = subnetworks(:one)
  end

  test "visiting the index" do
    visit subnetworks_url
    assert_selector "h1", text: "Subnetworks"
  end

  test "creating a Subnetwork" do
    visit subnetworks_url
    click_on "New Subnetwork"

    fill_in "Name", with: @subnetwork.name
    fill_in "Network category", with: @subnetwork.network_category_id
    fill_in "Vlan", with: @subnetwork.vlan
    click_on "Create Subnetwork"

    assert_text "Subnetwork was successfully created"
    click_on "Back"
  end

  test "updating a Subnetwork" do
    visit subnetworks_url
    click_on "Edit", match: :first

    fill_in "Name", with: @subnetwork.name
    fill_in "Network category", with: @subnetwork.network_category_id
    fill_in "Vlan", with: @subnetwork.vlan
    click_on "Update Subnetwork"

    assert_text "Subnetwork was successfully updated"
    click_on "Back"
  end

  test "destroying a Subnetwork" do
    visit subnetworks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Subnetwork was successfully destroyed"
  end
end
