require "test_helper"
require "securerandom"

class NodesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def node_to_params(node)
    {
      name: node.name,
      hostname: node.hostname,
      domain: node.domain,
      duid: node.duid,
      logical: node.logical,
      virtual_machine: node.virtual_machine,
      specific: node.specific,
      public: node.public,
      dns: node.dns,
      note: node.note,
      user_id: node.user_id,
      host_id: node.host_id,
      place: place_to_params(node.place),
      hardware: hardware_to_params(node.hardware),
      operating_system: operating_system_to_params(node.operating_system),
      nics_attributes: node.nics.map { |nic| nic_to_params(nic) },
    }
  end

  def place_to_params(place)
    {
      area: place&.area,
      building: place&.building,
      floor: place&.floor,
      room: place&.room,
    }
  end

  def hardware_to_params(hardware)
    {
      device_type_id: hardware&.device_type_id,
      maker: hardware&.maker,
      product_name: hardware&.product_name,
      model_number: hardware&.model_number,
    }
  end

  def operating_system_to_params(operating_system)
    {
      os_category_id: operating_system&.os_category_id,
      name: operating_system&.name,
    }
  end

  def nic_to_params(nic)
    {
      id: nic&.id,
      _destroy: false,
      name: nic&.name,
      locked: nic&.locked,
      interface_type: nic&.interface_type,
      auth: nic&.auth,
      mac_address: nic&.mac_address,
      network_id: nic&.network_id,
      ipv4_config: nic&.ipv4_config,
      ipv4_address: nic&.ipv4_address,
      ipv6_config: nic&.ipv6_config,
      ipv6_address: nic&.ipv6_address,
    }
  end

  setup do
    @node = nodes(:desktop)
    model_name = Node.model_name.human
    @messages = {
      create_success: I18n.t("messages.success_action", model: model_name, action: I18n.t("actions.register")),
      create_failure: I18n.t("messages.failure_action", model: model_name, action: I18n.t("actions.register")),
      update_success: I18n.t("messages.success_action", model: model_name, action: I18n.t("actions.update")),
      update_failure: I18n.t("messages.failure_action", model: model_name, action: I18n.t("actions.update")),
      destroy_success: I18n.t("messages.success_action", model: model_name, action: I18n.t("actions.delete")),
      destroy_failure: I18n.t("messages.failure_action", model: model_name, action: I18n.t("actions.delete")),
      unauthenticated: I18n.t("devise.failure.unauthenticated"),
    }
  end

  # index

  test "admin should get index" do
    sign_in users(:admin)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(nodes(:other_desktop))}\"]"
  end

  test "user should get index" do
    sign_in users(:user)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(nodes(:other_desktop))}\"]", false
  end

  test "redirect to login INSTEAD OF get index" do
    get nodes_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "admin should show node" do
    sign_in users(:admin)
    get node_url(@node)
    assert_response :success
  end

  test "user should show node" do
    sign_in users(:user)
    get node_url(@node)
    assert_response :success
  end

  test "other should NOT show" do
    sign_in users(:other)
    get node_url(@node)
    assert_response :not_found
  end

  test "redirect to login INSTEAD OF show node" do
    get node_url(@node)
    assert_redirected_to new_user_session_path
  end

  # new

  test "admin should get new" do
    sign_in users(:admin)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "user should get new" do
    sign_in users(:user)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "other should get new" do
    sign_in users(:other)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0", false
  end

  test "redirect to login INSTEAD OF get new" do
    get new_node_url
    assert_redirected_to new_user_session_path
  end

  # edit

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_node_url(@node)
    assert_response :success
  end

  test "user should get edit" do
    sign_in users(:user)
    get edit_node_url(@node)
    assert_response :success
  end

  test "other should NOT get edit" do
    sign_in users(:other)
    get edit_node_url(@node)
    assert_response :not_found
  end

  test "redirect to login INSTEAD OF get edit" do
    get edit_node_url(@node)
    assert_redirected_to new_user_session_path
  end

  # create

  test "admin should create node" do
    sign_in users(:admin)
    new_node = node_to_params(@node)
    new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    assert_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:user).id, Node.last.user_id
  end

  test "user should create node" do
    sign_in users(:user)
    new_node = node_to_params(@node)
    new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    assert_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:user).id, Node.last.user_id
  end

  test "other should create node" do
    sign_in users(:other)
    new_node = node_to_params(@node)
    new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    assert_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:other).id, Node.last.user_id
  end

  test "redirect to login INSTEAD OF create node" do
    new_node = node_to_params(@node)
    new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:unauthenticated], flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "user should NOT create node with same duid" do
    sign_in users(:user)
    new_node = node_to_params(@node)
    # new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  # update

  test "admin should update node" do
    sign_in users(:admin)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  test "user should update node" do
    sign_in users(:user)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  test "other should NOT update node" do
    sign_in users(:other)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_response :not_found
  end

  test "redirect to login INSTEAD OF update node" do
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to new_user_session_path
  end

  # destroy

  test "admin should destroy node" do
    sign_in users(:admin)
    assert_difference("Node.count", -1) do
      delete node_url(@node)
    end
    assert_redirected_to nodes_url
  end

  test "user should destroy node" do
    sign_in users(:user)
    assert_difference("Node.count", -1) do
      delete node_url(@node)
    end
    assert_redirected_to nodes_url
  end

  test "other should destroy node" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      delete node_url(@node)
    end
    assert_response :not_found
  end

  test "redirect to login INSTEAD OF destroy node" do
    assert_no_difference("Node.count") do
      delete node_url(@node)
    end
    assert_redirected_to new_user_session_path
  end

  # copy

  # transfer
end
