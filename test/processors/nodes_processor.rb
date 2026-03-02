require "test_helper"

class NodesProcessorTest < ActiveSupport::TestCase
  def node_to_params(node)
    {
      name: node.name,
      hostname: node.hostname,
      domain: node.domain,
      duid: node.duid,
      node_type: node.node_type,
      disabled: node.disabled,
      permanent: node.permanent,
      specific: node.specific,
      public: node.public,
      dns: node.dns,
      note: node.note,
      user_id: node.user_id,
      host_id: node.host_id,
      place: place_to_params(node.place),
      hardware: hardware_to_params(node.hardware),
      operating_system: operating_system_to_params(node.operating_system),
      nics_attributes: node.nics&.map { |nic| nic_to_params(nic) }
        &.each_with_index.to_a.to_h(&:reverse),
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
    @node_processor = NodesProcessor.new(users(:user))
    @node = nodes(:desktop)
  end

  test "user" do
    assert_not @node_processor.has_privilege?
  end

  test "admin" do
    node_processor = NodesProcessor.new(users(:admin))
    assert node_processor.has_privilege?
  end

  test "create node" do
    params = node_to_params(@node)
    assert_difference("Node.count") do
      @node_processor.create(params)
    end
    assert_equal @node.name, Node.last.name
  end
end
