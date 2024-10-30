require "test_helper"

class BulkRunJobTest < ActiveJob::TestCase
  test "run import Node" do
    bulk = bulks(:import_node)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "succeeded", bulk.status
    assert_equal input_size, bulk.number
    assert_equal input_size, bulk.success
    assert_equal 0, bulk.failure
    assert_equal input_size, output.size
  end

  test "admin run import Node" do
    bulk = bulks(:import_node)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "succeeded", bulk.status
    assert_equal input_size, bulk.number
    assert_equal input_size, bulk.success
    assert_equal 0, bulk.failure
    assert_equal input_size, output.size
  end

  test "run import Node NG" do
    bulk = bulks(:import_node_ng)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "failed", bulk.status
    assert_equal input_size, bulk.number
    assert_equal 0, bulk.success
    assert_equal input_size, bulk.failure
    assert_equal input_size, output.size

    output.each do |result|
      assert_equal "failed", result["[result]"]
    end
  end

  test "admin run import Node NG" do
    bulk = bulks(:import_node_ng)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "failed", bulk.status
    assert_equal input_size, bulk.number
    assert_equal 0, bulk.success
    assert_equal input_size, bulk.failure
    assert_equal input_size, output.size

    output.each do |result|
      assert_equal "failed", result["[result]"]
    end
  end

  test "run import Node only admin" do
    bulk = bulks(:import_node_admin)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "failed", bulk.status
    assert_equal input_size, bulk.number
    assert_equal 0, bulk.success
    assert_equal input_size, bulk.failure
    assert_equal input_size, output.size

    output.each do |result|
      assert_equal "failed", result["[result]"]
    end
  end

  test "admin run import Node only admin" do
    bulk = bulks(:import_node_admin)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "succeeded", bulk.status
    assert_equal input_size, bulk.number
    assert_equal input_size, bulk.success
    assert_equal 0, bulk.failure
    assert_equal input_size, output.size
  end



  test "run export Node" do
    bulk = bulks(:export_node)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    node_and_nic_count = bulk.user.nodes.sum { |node| [node.nics.count, 1].max }
    assert_equal node_and_nic_count, output.size
    assert_equal Node.find(output[0]["id"]).name, output[0]["name"]
  end

  test "admin run export all Node" do
    bulk = bulks(:export_node)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    node_and_nic_count = Node.all.sum { |node| [node.nics.count, 1].max }
    assert_equal node_and_nic_count, output.size
    assert_equal Node.find(output[0]["id"]).name, output[0]["name"]
  end

  test "run import Network" do
    bulk = bulks(:import_network)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "failed", bulk.status
  end

  test "admin run import Network" do
    bulk = bulks(:import_network)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "succeeded", bulk.status
    assert_equal input_size, bulk.number
    assert_equal input_size, bulk.success
    assert_equal 0, bulk.failure
    assert_equal input_size, output.size
  end

  test "admin run import Network with empty" do
    bulk = bulks(:import_network)
    bulk.update(user: users(:admin))
    network = networks(:client)
    csv_io = StringIO.new <<~CSV
      id,name,vlan,domain,domain_search,flag,ra,ipv4_network,ipv4_gateway,ipv4_dns_servers,ipv4_pools,ipv6_network,ipv6_gateway,ipv6_dns_servers,ipv6_pools,note,[result],[message]
      #{network.id},,,,,,,,,,,,,,,,,
    CSV
    bulk.input.attach(io: csv_io, filename: "test.csv",
      content_type: "text/csv", identify: false)

    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status

    updated_network = Network.find(network.id)

    assert_equal network.name, updated_network.name
    assert_equal network.vlan, updated_network.vlan
    assert_equal network.domain, updated_network.domain
    assert_equal network.domain_search_data, updated_network.domain_search_data
    assert_equal network.flag, updated_network.flag
    assert_equal network.ra, updated_network.ra
    assert_equal network.ipv4_network_prefix,
      updated_network.ipv4_network_prefix
    assert_equal network.ipv4_gateway, updated_network.ipv4_gateway
    assert_equal network.ipv4_dns_servers_data,
      updated_network.ipv4_dns_servers_data
    assert_equal network.ipv4_pools, updated_network.ipv4_pools
    assert_equal network.ipv6_network_prefix,
      updated_network.ipv6_network_prefix
    assert_equal network.ipv6_gateway, updated_network.ipv6_gateway
    assert_equal network.ipv6_dns_servers_data,
      updated_network.ipv6_dns_servers_data
    assert_equal network.ipv6_pools, updated_network.ipv6_pools
    assert_equal network.note, updated_network.note
  end

  test "admin run import Network with nil" do
    bulk = bulks(:import_network)
    bulk.update(user: users(:admin))
    network = networks(:client)
    csv_io = StringIO.new <<~CSV
      id,name,vlan,domain,domain_search,flag,ra,ipv4_network,ipv4_gateway,ipv4_dns_servers,ipv4_pools,ipv6_network,ipv6_gateway,ipv6_dns_servers,ipv6_pools,note,[result],[message]
      #{network.id},test,!,!,!,!,disabled,!,!,!,!,!,!,!,!,!,,
    CSV
    bulk.input.attach(io: csv_io, filename: "test.csv",
      content_type: "text/csv", identify: false)

    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status

    updated_network = Network.find(network.id)

    assert_equal "test", updated_network.name
    assert_nil updated_network.vlan
    assert_nil updated_network.domain
    assert_equal [], updated_network.domain_search_data
    assert_nil updated_network.flag
    assert_equal "disabled", updated_network.ra
    assert_nil updated_network.ipv4_network_prefix
    assert_nil updated_network.ipv4_gateway
    assert_equal [], updated_network.ipv4_dns_servers_data
    assert_equal [], updated_network.ipv4_pools
    assert_nil updated_network.ipv6_network_prefix
    assert_nil updated_network.ipv6_gateway
    assert_equal [], updated_network.ipv6_dns_servers_data
    assert_equal [], updated_network.ipv6_pools
    assert_nil updated_network.note
  end

  test "run export Network" do
    bulk = bulks(:export_network)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    assert_equal bulk.user.networks.count, output.size
    assert_equal Network.find(output[0]["id"]).name, output[0]["name"]
  end

  test "admin run export all Network" do
    bulk = bulks(:export_network)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    assert_equal Network.count, output.size
    assert_equal Network.find(output[0]["id"]).name, output[0]["name"]
  end

  test "run import User" do
    bulk = bulks(:import_user)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    assert_equal "failed", bulk.status
  end

  test "admin run import User" do
    bulk = bulks(:import_user)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    input_size = bulk.input.open do |file|
      CSV.table(file, header_converters: :downcase, encoding: "BOM|UTF-8").size
    end
    output = bulk.output.open do |file|
      assert_equal String.new("\u{feff}", encoding: "ASCII-8BIT"), file.read(3)
      file.rewind
      CSV.table(file, header_converters: :downcase,
        encoding: "BOM|UTF-8").map(&:to_hash)
    end

    assert_equal "succeeded", bulk.status
    assert_equal input_size, bulk.number
    assert_equal input_size, bulk.success
    assert_equal 0, bulk.failure
    assert_equal input_size, output.size
  end

  test "run export User" do
    bulk = bulks(:export_user)
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    assert_equal "succeeded", bulk.status
    assert_equal 1, output.size
    assert_equal bulk.user.username, output[0]["username"]
  end

  test "admin run export all User" do
    bulk = bulks(:export_user)
    bulk.update(user: users(:admin))
    perform_enqueued_jobs do
      BulkRunJob.perform_later(bulk)
    end

    bulk = Bulk.find(bulk.id)
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    assert_equal "succeeded", bulk.status
    assert_equal User.count, output.size
  end
end
