require "test_helper"

class NodesProcessorTest < ActiveSupport::TestCase
  def node_to_params(node)
    {
      user: node.user.username,
      name: node.name,
      fqdn: node.fqdn,
      type: node.node_type,
      flag: node.flag,
      components: node.components&.map(&:identifier),
      host: node.host&.identifier,
      place: place_to_params(node.place),
      hardware: hardware_to_params(node.hardware),
      operating_system: operating_system_to_params(node.operating_system),
      duid: node.duid,
      nics: node.nics&.map { |nic| nic_to_params(nic) },
      note: node.note,
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
      device_type: hardware&.device_type&.name,
      maker: hardware&.maker,
      product_name: hardware&.product_name,
      model_number: hardware&.model_number,
    }
  end

  def operating_system_to_params(operating_system)
    {
      os_category: operating_system&.os_category.name,
      name: operating_system&.name,
    }
  end

  def nic_to_params(nic)
    {
      number: nic&.number,
      name: nic&.name,
      interface_type: nic&.interface_type,
      network: nic&.network&.identifier,
      flag: nic&.flag,
      mac_address: nic&.mac_address,
      ipv4_config: nic&.ipv4_config,
      ipv4_address: nic&.ipv4_address,
      ipv6_config: nic&.ipv6_config,
      ipv6_address: nic&.ipv6_address,
    }
  end

  setup do
    @user = users(:user)
    @processor = NodesProcessor.new(@user)
    @node = nodes(:node)
  end

  test "serialize node" do
    assert_equal node_to_params(@node), @processor.serialize(@node)
  end

  test "ids" do
    ids = @processor.ids

    assert_includes ids, @node.id
    assert_not_includes ids, nodes(:other_desktop).id
  end

  test "index nodes" do
    nodes = @processor.index

    assert_includes nodes, @node
    assert_not_includes nodes, nodes(:other_desktop)
  end

  test "show node" do
    assert_equal @node.name, @processor.show(@node.id)[:name]
  end

  test "create node" do
    params = node_to_params(@node)
    params[:fqdn] = "new.example.jp"
    params[:duid] = "00-04-11-22-33-44-55-66"
    params[:nics][0][:mac_address] = "33-11-22-33-44-FF"
    assert_difference("Node.count") do
      @processor.create(params)
    end
    assert_equal @node.name, Node.last.name
    assert_equal @node.place_id, Node.last.place_id
    assert_equal @node.hardware_id, Node.last.hardware_id
    assert_equal @node.operating_system_id, Node.last.operating_system_id
    assert_equal params.except(:nics), @processor.serialize(Node.last).except(:nics)
    assert_equal params[:nics][0][:mac_address], Node.last.nics.first.mac_address
  end

  test "update node" do
    params = node_to_params(@node)
    params[:name] = "Updated Name"
    params[:place][:room] = "Updated Room"
    params[:hardware][:product_name] = "Updated Product Name"
    params[:operating_system][:name] = "Updated OS Name"
    assert_no_difference("Node.count") do
      @processor.update(@node.id, params)
    end
    @node.reload

    assert_equal "Updated Name", @node.name
    assert_equal "Updated Room", @node.place.room
    assert_equal "Updated Product Name", @node.hardware.product_name
    assert_equal "Updated OS Name", @node.operating_system.name
  end

  test "update node add nic" do
    params = node_to_params(@node)
    params[:nics] = [{
      **params[:nics][0],
      number: nil,
      mac_address: "00-11-22-33-44-FF",
    }]
    assert_difference("Nic.count") do
      @processor.update(@node.id, params)
    end
    @node.reload

    assert_equal 2, @node.nics.count
    assert_equal 2, Nic.last.number
  end

  test "update node delete nic" do
    params = node_to_params(@node)
    params[:nics][0][:_destroy] = true
    assert_difference("Nic.count", -1) do
      @processor.update(@node.id, params)
    end
    @node.reload

    assert_equal 0, @node.nics.count
  end

  test "desroy node" do
    assert_difference("Node.count", -1) do
      @processor.destroy(@node.id)
    end
  end

  # admin

  test "admin: index nodes" do
    @processor = NodesProcessor.new(users(:admin))
    nodes = @processor.index

    assert_includes nodes, @node
    assert_includes nodes, nodes(:other_desktop)
  end

  test "admin: show node" do
    @processor = NodesProcessor.new(users(:admin))

    assert_equal @node.name, @processor.show(@node.id)[:name]
  end

  test "admin: create node" do
    @processor = NodesProcessor.new(users(:admin))
    params = node_to_params(@node)
    params[:fqdn] = "new.example.jp"
    params[:duid] = "00-04-11-22-33-44-55-66"
    params[:nics][0][:mac_address] = "00-11-22-33-44-FF"
    assert_difference("Node.count") do
      @processor.create(params)
    end
    assert_equal @node.name, Node.last.name
    assert_equal @node.place_id, Node.last.place_id
    assert_equal @node.hardware_id, Node.last.hardware_id
    assert_equal @node.operating_system_id, Node.last.operating_system_id
    assert_equal params.except(:nics), @processor.serialize(Node.last).except(:nics)
    assert_equal params[:nics][0][:mac_address], Node.last.nics.first.mac_address
  end

  test "admin: update node" do
    @processor = NodesProcessor.new(users(:admin))
    params = node_to_params(@node)
    params[:name] = "Updated Name"
    params[:place][:room] = "Updated Room"
    params[:hardware][:product_name] = "Updated Product Name"
    params[:operating_system][:name] = "Updated OS Name"
    assert_no_difference("Node.count") do
      @processor.update(@node.id, params)
    end
    @node.reload

    assert_equal "Updated Name", @node.name
    assert_equal "Updated Room", @node.place.room
    assert_equal "Updated Product Name", @node.hardware.product_name
    assert_equal "Updated OS Name", @node.operating_system.name
  end

  test "admin: desroy node" do
    @processor = NodesProcessor.new(users(:admin))
    assert_difference("Node.count", -1) do
      @processor.destroy(@node.id)
    end
  end
end
