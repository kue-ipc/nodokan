require "application_system_test_case"

class ConfirmationsTest < ApplicationSystemTestCase
  setup do
    @confirmation = confirmations(:one)
  end

  test "visiting the index" do
    visit confirmations_url
    assert_selector "h1", text: "Confirmations"
  end

  test "creating a Confirmation" do
    visit confirmations_url
    click_on "New Confirmation"

    fill_in "Existence", with: @confirmation.existence
    fill_in "Ms upadte", with: @confirmation.ms_upadte
    fill_in "Node", with: @confirmation.node_id
    fill_in "Os update", with: @confirmation.os_update
    fill_in "Registered content", with: @confirmation.registered_content
    fill_in "Security software name", with: @confirmation.security_software_name
    fill_in "Securiy software", with: @confirmation.securiy_software
    fill_in "Securiyt software update", with: @confirmation.securiyt_software_update
    fill_in "Soft update,", with: @confirmation.soft_update,
    fill_in "Store update", with: @confirmation.store_update
    fill_in "Updated date", with: @confirmation.updated_date
    fill_in "User", with: @confirmation.user_id
    click_on "Create Confirmation"

    assert_text "Confirmation was successfully created"
    click_on "Back"
  end

  test "updating a Confirmation" do
    visit confirmations_url
    click_on "Edit", match: :first

    fill_in "Existence", with: @confirmation.existence
    fill_in "Ms upadte", with: @confirmation.ms_upadte
    fill_in "Node", with: @confirmation.node_id
    fill_in "Os update", with: @confirmation.os_update
    fill_in "Registered content", with: @confirmation.registered_content
    fill_in "Security software name", with: @confirmation.security_software_name
    fill_in "Securiy software", with: @confirmation.securiy_software
    fill_in "Securiyt software update", with: @confirmation.securiyt_software_update
    fill_in "Soft update,", with: @confirmation.soft_update,
    fill_in "Store update", with: @confirmation.store_update
    fill_in "Updated date", with: @confirmation.updated_date
    fill_in "User", with: @confirmation.user_id
    click_on "Update Confirmation"

    assert_text "Confirmation was successfully updated"
    click_on "Back"
  end

  test "destroying a Confirmation" do
    visit confirmations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Confirmation was successfully destroyed"
  end
end
