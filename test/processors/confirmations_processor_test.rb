require "test_helper"

class ConfirmationsProcessorTest < ActiveSupport::TestCase
  def node_to_confirmation_params(node)
    {
      name: node.name,
      address: node_address(node),
      os_category: node.operating_system&.os_category&.name,
      status: node.confirmation_status,
      existence: node.confirmation_or_build.existence,
      content: node.confirmation_or_build.content,
      os_update: node.confirmation_or_build.os_update,
      app_update: node.confirmation_or_build.app_update,
      software: node.confirmation_or_build.software,
      security_hardwares: node.confirmation_or_build.security_hardwares,
      security_software: {
        installation_method: node.confirmation_or_build.security_software&.installation_method,
        name: node.confirmation_or_build.security_software&.name,
      },
      security_update: node.confirmation_or_build.security_update,
      security_scan: node.confirmation_or_build.security_scan,
    }
  end

  def node_address(node)
    if node.domain.present?
      node.fqdn
    elsif (nic = node.nics.find(&:has_ipv4?))
      nic.ipv4_address
    elsif (nic = node.nics.find(&:has_ipv6?))
      nic.ipv6_address
    elsif (nic = node.nics.find(&:has_mac_address?))
      nic.mac_address
    elsif node.duid.present?
      node.duid
    else
      ""
    end
  end

  setup do
    @user = users(:user)
    @processor = ConfirmationsProcessor.new(@user)
    @node = nodes(:node)
  end

  test "serialize confirmation" do
    assert_equal node_to_confirmation_params(@node), @processor.serialize(@node)
  end

  test "ids" do
    ids = @processor.ids
    assert_includes ids, @node.id
    assert_not_includes ids, nodes(:other_desktop).id
  end

  test "index confirmations" do
    nodes = @processor.index
    assert_includes nodes, @node
    assert_not_includes nodes, nodes(:other_desktop)
  end

  test "show confirmation" do
    assert_equal @node.name, @processor.show(@node.id)[:name]
  end

  test "create confirmation" do
    params = node_to_confirmation_params(@node)
    assert_raise do
      @processor.create(params)
    end
  end

  test "update confirmation" do
    params = node_to_confirmation_params(@node)
    @processor.update(@node.id, params)
    @node.reload
    assert_in_delta Time.current, @node.confirmation.confirmed_at, 1.minute
  end

  test "update confirmation of other" do
    @node = nodes(:other_desktop)
    params = node_to_confirmation_params(@node)
    assert_raise Pundit::NotAuthorizedError do
      @processor.update(@node.id, params)
    end
  end


  test "desroy confirmation" do
    assert_raise do
      @processor.destroy(@node.id)
    end
  end

  # admin

  test "admin: index confirmations" do
    @processor = ConfirmationsProcessor.new(users(:admin))
    nodes = @processor.index
    assert_includes nodes, @node
    assert_includes nodes, nodes(:other_desktop)
  end

  test "admin: show confirmation" do
    @processor = ConfirmationsProcessor.new(users(:admin))
    assert_equal @node.name, @processor.show(@node.id)[:name]
  end

  test "admin: create confirmation" do
    @processor = ConfirmationsProcessor.new(users(:admin))
    assert_raise do
      @processor.create(params)
    end
  end

  test "admin: update confirmation" do
    @processor = ConfirmationsProcessor.new(users(:admin))
    params = node_to_confirmation_params(@node)
    @processor.update(@node.id, params)
    @node.reload
    assert_in_delta Time.current, @node.confirmation.confirmed_at, 1.minute
  end

  test "admin: desroy confirmation" do
    @processor = ConfirmationsProcessor.new(users(:admin))
    assert_raise do
      @processor.destroy(@node.id)
    end
  end
end
