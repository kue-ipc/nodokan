require "test_helper"
require "securerandom"

class NodesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def hex_to_binary(str)
    [str.delete("-:")].pack("H*")
  end

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
      nics_attributes: node.nics&.map { |nic| nic_to_params(nic) }&.each_with_index.to_a.to_h(&:reverse),
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

  test "should get index" do
    sign_in users(:user)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(nodes(:other_desktop))}\"]", false
  end

  test "admin should get index" do
    sign_in users(:admin)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(nodes(:other_desktop))}\"]"
  end

  test "other should get index" do
    sign_in users(:other)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]", false
    assert_select "a[href=\"#{node_path(nodes(:other_desktop))}\"]"
  end

  test "guest redirect to login INSTEAD OF get index" do
    get nodes_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "should show node" do
    sign_in users(:user)
    get node_url(@node)
    assert_response :success
  end

  test "admin should show node" do
    sign_in users(:admin)
    get node_url(@node)
    assert_response :success
  end

  test "other should NOT show" do
    sign_in users(:other)
    get node_url(@node)
    assert_response :not_found
  end

  test "guest redirect to login INSTEAD OF show node" do
    get node_url(@node)
    assert_redirected_to new_user_session_path
  end

  # new

  test "should get new" do
    sign_in users(:user)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "guest redirect to login INSTEAD OF get new" do
    get new_node_url
    assert_redirected_to new_user_session_path
  end

  # edit

  test "should get edit" do
    sign_in users(:user)
    get edit_node_url(@node)
    assert_response :success
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_node_url(@node)
    assert_response :success
  end

  test "other should NOT get edit" do
    sign_in users(:other)
    get edit_node_url(@node)
    assert_response :not_found
  end

  test "guest redirect to login INSTEAD OF get edit" do
    get edit_node_url(@node)
    assert_redirected_to new_user_session_path
  end

  # create

  test "should create node" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name"}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:user).id, Node.last.user_id
  end

  test "admin should create node" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name"}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.user_id
  end

  test "guest redirect to login INSTEAD OF create node" do
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {name: "name"}}
    end
    assert_equal @messages[:unauthenticated], flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "should create node all attributes" do
    sign_in users(:user)
    new_node = node_to_params(@node)
    new_node[:hostname] = "new"
    new_node[:duid] = "00-04-#{SecureRandom.uuid}"
    new_node[:nics_attributes][0][:id] = nil
    new_node[:nics_attributes][0][:mac_address] = "00-11-22-33-44-FF"
    new_node[:nics_attributes][0][:ipv4_address] = nil
    new_node[:nics_attributes][0][:ipv6_address] = nil

    new_node[:logical] = false
    new_node[:virtual_machine] = false
    assert_difference("Node.count") do
      post nodes_url, params: {node: new_node}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal @node.name, Node.last.name
    assert_equal new_node[:hostname], Node.last.hostname
    assert_equal @node.domain, Node.last.domain
    assert_equal hex_to_binary(new_node[:duid]), Node.last.duid_data
    # @node not logical and virtual_machine
    assert_not Node.last.logical
    assert_not Node.last.virtual_machine
    assert_not Node.last.specific
    assert_not Node.last.public
    assert_not Node.last.dns
    assert_equal users(:user).id, Node.last.user_id
    assert_nil Node.last.host_id
    assert_equal [], Node.last.component_ids
    assert_equal @node.place_id, Node.last.place_id
    assert_equal @node.hardware_id, Node.last.hardware_id
    assert_equal @node.operating_system_id, Node.last.operating_system_id
    assert_equal @node.nics.count, Node.last.nics.count
    assert_not_equal @node.nics.first.id, Node.last.nics.first.id
    assert_equal @node.nics.first.name, Node.last.nics.first.name
    assert_not Node.last.nics.first.locked
    assert_equal @node.nics.first.interface_type, Node.last.nics.first.interface_type
    assert_equal @node.nics.first.auth, Node.last.nics.first.auth
    assert_equal hex_to_binary(new_node[:nics_attributes][0][:mac_address]), Node.last.nics.first.mac_address_data
    assert_equal @node.nics.first.network_id, Node.last.nics.first.network_id
    assert_equal @node.nics.first.ipv4_config, Node.last.nics.first.ipv4_config
    assert_not_equal @node.nics.first.ipv4_data, Node.last.nics.first.ipv4_data
    assert_equal @node.nics.first.ipv6_config, Node.last.nics.first.ipv6_config
    assert_not_equal @node.nics.first.ipv6_data, Node.last.nics.first.ipv6_data
  end

  test "should NOT create node without name" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {hostname: "hostname"}}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with same hostname and same domain" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: @node.hostname, domain: @node.domain}}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should create node with different hostname and different domain" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: "hostname", domain: "domain.example.jp"}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal "hostname", Node.last.hostname
    assert_equal "domain.example.jp", Node.last.domain
  end

  test "should create node with different hostname and same domain" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: "hostname", domain: @node.domain}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal "hostname", Node.last.hostname
    assert_equal @node.domain, Node.last.domain
  end

  test "should create node with same hostname and different domain" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: @node.hostname, domain: "domain.example.jp"}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal @node.hostname, Node.last.hostname
    assert_equal "domain.example.jp", Node.last.domain
  end

  test "should create node with same hostname and without domain" do
    sign_in users(:user)
    no_domain_node = nodes(:note)
    assert_nil no_domain_node.domain
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: no_domain_node.hostname, domain: no_domain_node.domain}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal no_domain_node.hostname, Node.last.hostname
    assert_nil Node.last.domain
  end

  test "should NOT create node without hostname and with domain" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", hostname: nil, domain: "test.example.jp"}}
    end
  end

  test "should NOT create node with same duid" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", duid: @node.duid}}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should create node with logical" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        logical: true,
        virtual_machine: true,
        component_ids: [@node.id],
        host_id: @node.id,
        place: place_to_params(@node.place),
        hardware: hardware_to_params(@node.hardware),
        operating_system: operating_system_to_params(@node.operating_system),
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.logical
    assert_equal [@node.id], Node.last.component_ids
    # ignore attributes
    assert_not Node.last.virtual_machine
    assert_nil Node.last.host_id
    assert_nil Node.last.place
    assert_nil Node.last.hardware
    assert_nil Node.last.operating_system
  end

  test "should create node with virtual_machine" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        logical: false,
        virtual_machine: true,
        component_ids: [@node.id],
        host_id: @node.id,
        place: place_to_params(@node.place),
        hardware: hardware_to_params(@node.hardware),
        operating_system: operating_system_to_params(@node.operating_system),
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not Node.last.logical
    assert Node.last.virtual_machine
    assert_equal @node.id, Node.last.host_id
    assert_equal @node.hardware_id, Node.last.hardware_id
    assert_equal @node.operating_system_id, Node.last.operating_system_id
    # ignore attributes
    assert_nil Node.last.place
    assert_empty Node.last.component_ids
  end

  test "should create node with flags, but ignored" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", specific: true, public: true, dns: true}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    # ignore attributes
    assert_not Node.last.specific
    assert_not Node.last.public
    assert_not Node.last.dns
  end

  test "admin should create node with flags" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", specific: true, public: true, dns: true}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.specific
    assert Node.last.public
    assert Node.last.dns
  end

  test "should create node with user_id, but ignored" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", user_id: users(:other).id}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:user).id, Node.last.user_id
  end

  test "admin should create node with user_id" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {name: "name", user_id: users(:other).id}}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal users(:other).id, Node.last.user_id
  end

  test "should create node with new place" do
    sign_in users(:user)
    assert_difference("Place.count") do
      assert_difference("Node.count") do
        post nodes_url, params: {node: {name: "name", place: {**place_to_params(@node.place), room: "other"}}}
      end
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not_equal @node.place_id, Node.last.place_id
  end

  test "should create node with new hardware" do
    sign_in users(:user)
    assert_difference("Hardware.count") do
      assert_difference("Node.count") do
        post nodes_url,
          params: {node: {name: "name", hardware: {**hardware_to_params(@node.hardware), product_name: "other"}}}
      end
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not_equal @node.hardware_id, Node.last.hardware_id
  end

  test "should create node with new operating_system" do
    sign_in users(:user)
    assert_difference("OperatingSystem.count") do
      assert_difference("Node.count") do
        post nodes_url, params: {node: {
          name: "name",
          operating_system: {**operating_system_to_params(@node.operating_system), name: "other"},
        }}
      end
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not_equal @node.operating_system_id, Node.last.operating_system_id
  end

  test "should create node with nic" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal 1, Node.last.nics.count
  end

  test "should NOT create node with nic without interface_type" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          # interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with nic without nework_id" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          # network_id: @node.nics.first.network_id,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should create node with two nics " do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {
          0 => {
            interface_type: @node.nics.first.interface_type,
            network_id: @node.nics.first.network_id,
          },
          1 => {
            interface_type: @node.nics.first.interface_type,
            network_id: @node.nics.first.network_id,
          },
        },
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal 2, Node.last.nics.count
  end

  test "should create node with deleted nic " do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          _destroy: true,
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal 0, Node.last.nics.count
  end

  test "should create node with nic id, but ignored" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          id: @node.nics.first.id,
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not_equal @node.nic_ids.first, Node.last.nic_ids.first
  end

  test "should NOT create node with same mac_address" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: @node.nics.first.mac_address,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should create node with auth and mac_address" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          auth: true,
          mac_address: "00-11-22-33-44-FF",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.auth
    assert_equal hex_to_binary("00-11-22-33-44-FF"), Node.last.nics.first.mac_address_data
  end

  test "should NOT create node without mac_address and with auth" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          auth: true,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should create node with nic locked, but ingore" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          locked: true,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_not Node.last.nics.first.locked
  end

  test "admin should create node with nic locked" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          locked: true,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.locked
  end

  ## ip config and address

  ### unmanageable

  #### dynamic

  test "should create node with dynamic ipv4/ipv6" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "dynamic",
          ipv6_config: "dynamic",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  test "should create node with dynamic ipv4/ipv6, same addresses, but ignore" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "dynamic",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "dynamic",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  #### reserved

  test "should create node with reserved ipv4/ipv6, mac_address, duid" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv4_config: "reserved",
          ipv6_config: "reserved",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4_data
    assert Node.last.nics.first.ipv6_data
  end

  test "should create node with reserved ipv4/ipv6, mac_address, duid, same addresses, but ignore" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv4_config: "reserved",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "reserved",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4
    assert Node.last.nics.first.ipv6
    assert_not_equal @node.nics.first.ipv4_data, Node.last.nics.first.ipv4_data
    assert_not_equal @node.nics.first.ipv6_data, Node.last.nics.first.ipv6_data
  end

  test "should NOT create node with resrved ipv4, without mac_address" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "reserved",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with reserved ipv6 and without duid" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv6_config: "reserved",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  #### static

  test "should create node with static ipv4/ipv6" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "static",
          ipv6_config: "static",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4_data
    assert Node.last.nics.first.ipv6_data
  end

  test "should create node with static ipv4/ipv6, same addresses, but ignore" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "static",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "static",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4_data
    assert Node.last.nics.first.ipv6_data
    assert_not_equal @node.nics.first.ipv4_data, Node.last.nics.first.ipv4_data
    assert_not_equal @node.nics.first.ipv6_data, Node.last.nics.first.ipv6_data
  end

  #### manual

  test "should NOT create node with manual ipv4" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "manual",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with manual ipv4, address" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "manual",
          ipv4_address: "192.168.2.241",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with manual ipv6" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv6_config: "manual",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "should NOT create node with manual ipv6, address" do
    sign_in users(:user)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv6_config: "manual",
          ipv6_address: "fd00:2::4001",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  #### disabled

  test "should create node with disabled ipv4/ipv6" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "disabled",
          ipv6_config: "disabled",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  test "should create node with disabled ipv4/ipv6, same addresses, but ignore" do
    sign_in users(:user)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "disabled",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "disabled",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  ### manageable
  # other manage client network

  #### dynamic

  test "other should create node with dynamic ipv4/ipv6" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "dynamic",
          ipv6_config: "dynamic",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  test "other should create node with dynamic ipv4/ipv6, same addresses, but ignore" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "dynamic",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "dynamic",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  #### reserved

  test "other should create node with reserved ipv4/ipv6, mac_address, duid" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv4_config: "reserved",
          ipv6_config: "reserved",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4_data
    assert Node.last.nics.first.ipv6_data
  end

  test "other should NOT create node with reserved ipv4/ipv6, mac_address, duid, same addresses, but ignore" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv4_config: "reserved",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "reserved",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "other should create node with reserved ipv4/ipv6, mac_address, duid, different addresses, but ignore" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        duid: "00-04-#{SecureRandom.uuid}",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          mac_address: "00-11-22-33-44-FF",
          ipv4_config: "reserved",
          ipv4_address: @node.nics.first.ipv4.succ.to_s,
          ipv6_config: "reserved",
          ipv6_address: @node.nics.first.ipv6.succ.to_s,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal @node.nics.first.ipv4.succ.hton, Node.last.nics.first.ipv4_data
    assert_equal @node.nics.first.ipv6.succ.hton, Node.last.nics.first.ipv6_data
  end

  #### static

  test "other should create node with static ipv4/ipv6" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "static",
          ipv6_config: "static",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert Node.last.nics.first.ipv4_data
    assert Node.last.nics.first.ipv6_data
  end

  test "other should create node with static ipv4/ipv6, different addresses, but ignore" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "static",
          ipv4_address: @node.nics.first.ipv4.succ.to_s,
          ipv6_config: "static",
          ipv6_address: @node.nics.first.ipv6.succ.to_s,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal @node.nics.first.ipv4.succ.hton, Node.last.nics.first.ipv4_data
    assert_equal @node.nics.first.ipv6.succ.hton, Node.last.nics.first.ipv6_data
  end

  test "other should NOT create node with static ipv4, same addresses, but ignore" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "static",
          ipv4_address: @node.nics.first.ipv4_address,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "other should NOT create node with static ipv6, same addresses, but ignore" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv6_config: "static",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  #### manual

  test "other should create node with manual ipv4/ipv6, address" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "manual",
          ipv4_address: "192.168.2.241",
          ipv6_config: "manual",
          ipv6_address: "fd00:2::4001",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_equal "192.168.2.241", Node.last.nics.first.ipv4_address
    assert_equal "fd00:2::4001", Node.last.nics.first.ipv6_address
  end

  test "other should NOT create node with manual ipv4 without address" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "manual",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  test "other should create node with manual ipv6 without address" do
    sign_in users(:other)
    assert_no_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv6_config: "manual",
        }},
      }}
    end
    assert_equal @messages[:create_failure], flash[:alert]
    assert_response :success
  end

  #### disabled

  test "other should create node with disabled ipv4/ipv6" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "disabled",
          ipv6_config: "disabled",
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  test "other should create node with disabled ipv4/ipv6, same addresses, but ignore" do
    sign_in users(:other)
    assert_difference("Node.count") do
      post nodes_url, params: {node: {
        name: "name",
        nics_attributes: {0 => {
          interface_type: @node.nics.first.interface_type,
          network_id: @node.nics.first.network_id,
          ipv4_config: "disabled",
          ipv4_address: @node.nics.first.ipv4_address,
          ipv6_config: "disabled",
          ipv6_address: @node.nics.first.ipv6_address,
        }},
      }}
    end
    assert_equal @messages[:create_success], flash[:notice]
    assert_redirected_to node_url(Node.last)
    assert_nil Node.last.nics.first.ipv4_data
    assert_nil Node.last.nics.first.ipv6_data
  end

  # update

  test "admin should update node" do
    sign_in users(:admin)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  test "should update node" do
    sign_in users(:user)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  test "other should NOT update node" do
    sign_in users(:other)
    patch node_url(@node), params: {node: {name: @node.name, note: @node.note}}
    assert_response :not_found
  end

  test "guest redirect to login INSTEAD OF update node" do
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

  test "should destroy node" do
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

  test "guest redirect to login INSTEAD OF destroy node" do
    assert_no_difference("Node.count") do
      delete node_url(@node)
    end
    assert_redirected_to new_user_session_path
  end

  # copy

  # transfer
end
