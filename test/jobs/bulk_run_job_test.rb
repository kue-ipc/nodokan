require "test_helper"

class BulkRunJobTest < ActiveJob::TestCase
  test "run import Node" do
    bulk = bulks(:import_node)
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
    node = Node.find(output[0]["id"])
    assert_equal "パソコン", node.name
    assert_equal "LAN", node.nics.first.name
  end

  test "run import Node NG" do
    bulk = bulks(:import_node_ng)
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
    node = Node.find(output[0]["id"])
    assert_equal "パソコン", node.name
    assert_equal "LAN", node.nics.first.name
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

  test "run export User" do
    bulk = bulks(:export_user)
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
    assert_equal "succeeded", bulk.status
    output = bulk.output.open do |data|
      data.set_encoding("UTF-8", "UTF-8")
      first_char = data.getc
      assert_equal "\u{feff}", first_char
      csv = CSV.new(data, headers: :first_row)
      csv.read.map(&:to_hash)
    end
    assert_equal User.count, output.size
    assert_equal bulk.user.username, output[0]["username"]
  end
end
