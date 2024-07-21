require "application_system_test_case"

class BulksTest < ApplicationSystemTestCase
  setup do
    @bulk = bulks(:one)
  end

  test "visiting the index" do
    visit bulks_url
    assert_selector "h1", text: "Bulks"
  end

  test "should create bulk" do
    visit bulks_url
    click_on "New bulk"

    fill_in "Model", with: @bulk.model
    fill_in "Started at", with: @bulk.started_at
    fill_in "Status", with: @bulk.status
    fill_in "Stopped at", with: @bulk.stopped_at
    fill_in "User", with: @bulk.user_id
    click_on "Create Bulk"

    assert_text "Bulk was successfully created"
    click_on "Back"
  end

  test "should update Bulk" do
    visit bulk_url(@bulk)
    click_on "Edit this bulk", match: :first

    fill_in "Model", with: @bulk.model
    fill_in "Started at", with: @bulk.started_at
    fill_in "Status", with: @bulk.status
    fill_in "Stopped at", with: @bulk.stopped_at
    fill_in "User", with: @bulk.user_id
    click_on "Update Bulk"

    assert_text "Bulk was successfully updated"
    click_on "Back"
  end

  test "should destroy Bulk" do
    visit bulk_url(@bulk)
    click_on "Destroy this bulk", match: :first

    assert_text "Bulk was successfully destroyed"
  end
end
