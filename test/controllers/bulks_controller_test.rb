require "test_helper"

class BulksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers

  setup do
    @bulk = bulks(:import)
  end

  # test "should get index" do
  #   get bulks_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_bulk_url
  #   assert_response :success
  # end

  test "should create bulk" do
    sign_in users(:user)
    assert_difference("Bulk.count") do
      assert_enqueued_with(job: BulkRunJob) do
        post bulks_url, params: {bulk: {
          target: @bulk.target, user_id: @bulk.user_id,
          input: file_fixture_upload("node.csv", "text/csv"),
        }}
      end
    end
    bulk = Bulk.last
    assert_redirected_to bulk_url(bulk)
    assert_equal "waiting", bulk.status
  end

  # test "should show bulk" do
  #   get bulk_url(@bulk)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_bulk_url(@bulk)
  #   assert_response :success
  # end

  # test "should update bulk" do
  #   patch bulk_url(@bulk),
  #     params: {bulk: {model: @bulk.model, started_at: @bulk.started_at,
  #                     status: @bulk.status, stopped_at: @bulk.stopped_at, user_id: @bulk.user_id,}}
  #   assert_redirected_to bulk_url(@bulk)
  # end

  # test "should destroy bulk" do
  #   assert_difference("Bulk.count", -1) do
  #     delete bulk_url(@bulk)
  #   end

  #   assert_redirected_to bulks_url
  # end
end
