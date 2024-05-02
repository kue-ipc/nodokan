require "test_helper"

class NetworksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def get_message(key)
    model_name = Network.model_name.human
    case key
    when :create_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.create"))
    when :create_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.create"))
    when :update_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.update"))
    when :update_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.update"))
    when :destroy_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.delete"))
    when :destroy_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.delete"))
    when :unauthenticated
      I18n.t("devise.failure.unauthenticated")
    end
  end

  def network_to_params(network)
    {
      name: network.name,
      vlan: network.vlan,
      auth: network.auth,
      locked: network.locked,
      specific: network.specific,
      dhcp: network.dhcp,
      ra: network.ra,
      ipv4_network_address: network.ipv4_network_address,
      ipv4_prefix_length: network.ipv4_prefix_length,
      ipv4_gateway_address: network.ipv4_gateway_address,
      ipv6_network_address: network.ipv6_network_address,
      ipv6_prefix_length: network.ipv6_prefix_length,
      ipv6_gateway_address: network.ipv6_gateway_address,
      note: network.note,
      ipv4_pools_attributes: network.ipv4_pools
        &.map { |ipv4_pool| ipv4_pool_to_params(ipv4_pool) }
        &.each_with_index.to_a.to_h(&:reverse),
      ipv6_pools_attributes: network.ipv6_pools
        &.map { |ipv6_pool| ipv6_pool_to_params(ipv6_pool) }
        &.each_with_index.to_a.to_h(&:reverse),
    }
  end

  def ipv4_pool_to_params(ipv4_pool)
    {
      id: ipv4_pool.id,
      _destroy: false,
      ipv4_config: ipv4_pool.ipv4_config,
      ipv4_first_address: ipv4_pool.ipv4_first_address,
      ipv4_last_address: ipv4_pool.ipv4_last_address,
    }
  end

  def ipv6_pool_to_params(ipv6_pool)
    {
      id: ipv6_pool.id,
      _destroy: false,
      ipv6_config: ipv6_pool.ipv6_config,
      ipv6_first_address: ipv6_pool.ipv6_first_address,
      ipv6_last_address: ipv6_pool.ipv6_last_address,
    }
  end

  def pool_params(version, config, first, last)
    {
      "ipv#{version}_config": config,
      "ipv#{version}_first_address": first,
      "ipv#{version}_last_address": last,
    }
  end

  setup do
    @network = networks(:client)
  end

  # index

  test "should get index" do
    sign_in users(:user)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]"
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]", false
  end

  test "admin should get index" do
    sign_in users(:admin)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]"
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]"
  end

  test "less should get index" do
    sign_in users(:less)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]", false
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]", false
  end

  test "guest redirect to login INSTEAD OF get index" do
    get networks_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "should show network" do
    sign_in users(:user)
    get network_url(@network)
    assert_response :success
  end

  test "admin should show network" do
    sign_in users(:admin)
    get network_url(@network)
    assert_response :success
  end

  test "less should NOT show network" do
    sign_in users(:less)
    get network_url(@network)
    assert_response :not_found
  end

  test "guest redirect to login INSTEAD OF show network" do
    get network_url(@network)
    assert_redirected_to new_user_session_path
  end

  # new

  test "should NOT get new" do
    sign_in users(:user)
    get new_network_url
    assert_response :forbidden
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_network_url
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get new" do
    get new_network_url
    assert_redirected_to new_user_session_path
  end

  # edit

  test "should NOT get edit" do
    sign_in users(:user)
    get edit_network_url(@network)
    assert_response :forbidden
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_network_url(@network)
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get edit" do
    get edit_network_url(@network)
    assert_redirected_to new_user_session_path
  end

  # create

  test "should NOT create network" do
    sign_in users(:user)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_response :forbidden
  end

  test "admin should create network" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "guest redirect to login INSTEAD OF create network" do
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_redirected_to new_user_session_path
  end

  test "admin should create network all" do
    sign_in users(:admin)
    new_params = network_to_params(@network)
    new_params.merge!({
      name: "name",
      vlan: 42,
      ipv4_network_address: "10.10.10.0",
      ipv4_gateway_address: "10.10.10.254",
      ipv6_network_address: "fd01:1::",
      ipv6_gateway_address: "fd01:1::1",
      ipv4_pools_attributes: {},
      ipv6_pools_attributes: {},
    })
    assert_difference("Network.count") do
      post networks_url, params: {network: new_params}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "admin should create network small" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ipv4_network_address: "10.10.10.0",
        ipv6_network_address: "fd01:1::",
      }}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "admin should NOT create network without name" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {vlan: 42}}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network same name" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: @network.name}}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network same vlan" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: "name", vlan: @network.vlan}}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network same ipv4" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ipv4_network_address: @network.ipv4_network_address,
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network same ipv6" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ipv6_network_address: @network.ipv6_network_address,
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network dhcp without ipv4" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: true,
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create network disabled ra without ipv6" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "disabled",
      }}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "admin should NOT create network ra without ipv6" do
    sign_in users(:admin)
    Network.ras.keys.reject { |v| v == "disabled" }.each do |v|
      assert_no_difference("Network.count") do
        post networks_url, params: {network: {
          name: "name",
          ra: v,
        }}
      end
      assert_response :success
      assert_equal get_message(:create_failure), flash[:alert]
    end
  end

  test "admin should NOT create network out range ipv4 gateway" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.20.254",
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should NOT create network out range ipv6 gateway" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:2::1",
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create network ipv4 with pools" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: true,
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.10.254",
        ipv4_pools_attributes: {
          0 => pool_params(4, "dynamic", "10.10.10.1", "10.10.10.10"),
          1 => pool_params(4, "reserved", "10.10.10.11", "10.10.10.20"),
          2 => pool_params(4, "static", "10.10.10.21", "10.10.10.30"),
          3 => pool_params(4, "manual", "10.10.10.31", "10.10.10.40"),
          4 => pool_params(4, "disabled", "10.10.10.41", "10.10.10.50"),
        },
      }}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "admin should create NOT network ipv4 with out range pool" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: true,
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.10.254",
        ipv4_pools_attributes: {
          0 => pool_params(4, "dynamic", "10.10.20.1", "10.10.20.10"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network ipv4 with revese pool" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: true,
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.10.254",
        ipv4_pools_attributes: {
          0 => pool_params(4, "dynamic", "10.10.10.10", "10.10.20.1"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network no dhcp ipv4 with dynamic" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: false,
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.10.254",
        ipv4_pools_attributes: {
          0 => pool_params(4, "dynamic", "10.10.10.1", "10.10.10.10"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network no dhcp ipv4 with reserved" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        dhcp: false,
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv4_gateway_address: "10.10.10.254",
        ipv4_pools_attributes: {
          0 => pool_params(4, "reserved", "10.10.10.1", "10.10.10.10"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create network ipv6 with pools" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "managed",
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "mapped", "fd01:1::", "fd01:1::ffff:ffff"),
          1 => pool_params(6, "dynamic", "fd01:1::1:0:0", "fd01:1::1:0:ffff"),
          2 => pool_params(6, "reserved", "fd01:1::1:1:0", "fd01:1::1:1:ffff"),
          3 => pool_params(6, "static", "fd01:1::1:2:0", "fd01:1::1:2:ffff"),
          4 => pool_params(6, "manual", "fd01:1::1:3:0", "fd01:1::1:3:ffff"),
          5 => pool_params(6, "disabled", "fd01:1::1:4:0", "fd01:1::1:4:ffff"),
        },
      }}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "admin should create NOT network ipv6 with out range pool" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "managed",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "dynamic", "fd01:2::1:0", "fd01:2::1:ffff"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network ipv6 with revese pool" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "managed",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "dynamic", "fd01:1::1:ffff", "fd0:1::1:0"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network no dhcp ipv6 with dynamic" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "stateless",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "dynamic", "fd01:1::1:0", "fd01:1::1:ffff"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network no dhcp ipv6 with reserved" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "stateless",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "reserved", "fd01:1::1:0", "fd01:1::1:ffff"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network inalid mapped end" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "stateless",
        ipv4_network_address: "10.10.10.0",
        ipv4_prefix_length: 24,
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "mapped", "fd01:1::", "fd01:1::ffff"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  test "admin should create NOT network mapped pool without ipv4" do
    sign_in users(:admin)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {
        name: "name",
        ra: "stateless",
        ipv6_network_address: "fd01:1::",
        ipv6_prefix_length: 64,
        ipv6_gateway_address: "fd01:1::1",
        ipv6_pools_attributes: {
          0 => pool_params(6, "mapped", "fd01:1::", "fd01:1::ffff:ffff"),
        },
      }}
    end
    assert_response :success
    assert_equal get_message(:create_failure), flash[:alert]
  end

  # udpate

  test "should NOT update network" do
    sign_in users(:user)
    patch network_url(@network), params: {network: {name: "name"}}
    assert_response :forbidden
  end

  test "admin should update network" do
    sign_in users(:admin)
    patch network_url(@network), params: {network: {name: "name"}}
    assert_redirected_to network_url(@network)
  end

  test "guest redirect to login INSTEAD OF update network" do
    patch network_url(@network), params: {network: {name: "name"}}
    assert_redirected_to new_user_session_path
  end

  # test 'should update network' do
  #   patch network_url(@network),
  #     params: { network: {
  #       auth: @network.auth, closed: @network.closed, dhcp: @network.dhcp,
  #       ipv6_address: @network.ipv6_address, ipv6_gateway: @network.ipv6_gateway,
  #       ipv6_prefix: @network.ipv6_prefix,
  #       ipv4_address: @network.ipv4_address, ipv4_gateway: @network.ipv4_gateway, ipv4_mask: @network.ipv4_mask,
  #       name: @network.name, vlan: @network.vlan,
  #     } }
  #   assert_redirected_to network_url(@network)
  # end

  # destroy

  test "should NOT destroy network" do
    sign_in users(:user)
    assert_no_difference("Network.count") do
      delete network_url(networks(:noip))
    end
    assert_response :forbidden
  end

  test "admin should destroy network" do
    sign_in users(:admin)
    assert_difference("Network.count", -1) do
      delete network_url(networks(:noip))
    end
    assert_redirected_to networks_url
  end

  test "guest redirect to login INSTEAD OF destroy network" do
    assert_no_difference("Network.count") do
      delete network_url(networks(:noip))
    end
    assert_redirected_to new_user_session_path
  end
end
