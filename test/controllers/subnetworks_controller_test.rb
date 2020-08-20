require 'test_helper'

class SubnetworksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subnetwork = subnetworks(:one)
  end

  test 'should get index' do
    get subnetworks_url
    assert_response :success
  end

  test 'should get new' do
    get new_subnetwork_url
    assert_response :success
  end

  test 'should create subnetwork' do
    assert_difference('Subnetwork.count') do
      post subnetworks_url, params: {subnetwork: {name: @subnetwork.name, network_category_id: @subnetwork.network_category_id, vlan: @subnetwork.vlan}}
    end

    assert_redirected_to subnetwork_url(Subnetwork.last)
  end

  test 'should show subnetwork' do
    get subnetwork_url(@subnetwork)
    assert_response :success
  end

  test 'should get edit' do
    get edit_subnetwork_url(@subnetwork)
    assert_response :success
  end

  test 'should update subnetwork' do
    patch subnetwork_url(@subnetwork), params: {subnetwork: {name: @subnetwork.name, network_category_id: @subnetwork.network_category_id, vlan: @subnetwork.vlan}}
    assert_redirected_to subnetwork_url(@subnetwork)
  end

  test 'should destroy subnetwork' do
    assert_difference('Subnetwork.count', -1) do
      delete subnetwork_url(@subnetwork)
    end

    assert_redirected_to subnetworks_url
  end
end
