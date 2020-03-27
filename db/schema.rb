# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_27_020243) do

  create_table "hardwares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "type"
    t.string "maker"
    t.string "product_name"
    t.string "model_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["maker"], name: "index_hardwares_on_maker"
    t.index ["model_number"], name: "index_hardwares_on_model_number"
    t.index ["product_name"], name: "index_hardwares_on_product_name"
  end

  create_table "ipv4_addresses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_connection_id", null: false
    t.boolean "dhcp"
    t.boolean "reserved"
    t.string "ip_address"
    t.string "mac_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip_address"], name: "index_ipv4_addresses_on_ip_address"
    t.index ["mac_address"], name: "index_ipv4_addresses_on_mac_address"
    t.index ["network_connection_id"], name: "index_ipv4_addresses_on_network_connection_id"
  end

  create_table "ipv4_networks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "subnetwork_id", null: false
    t.string "address", null: false
    t.string "subnet_mask"
    t.string "default_gateway"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address"], name: "index_ipv4_networks_on_address"
    t.index ["subnetwork_id"], name: "index_ipv4_networks_on_subnetwork_id"
  end

  create_table "ipv6_addresses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_connection_id", null: false
    t.boolean "dhcp"
    t.boolean "reserved"
    t.string "ip_address"
    t.string "mac_address"
    t.string "duid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip_address"], name: "index_ipv6_addresses_on_ip_address"
    t.index ["mac_address"], name: "index_ipv6_addresses_on_mac_address"
    t.index ["network_connection_id"], name: "index_ipv6_addresses_on_network_connection_id"
  end

  create_table "ipv6_networks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "subnetwork_id", null: false
    t.string "address", null: false
    t.integer "prefix_length"
    t.string "default_gateway"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address"], name: "index_ipv6_networks_on_address"
    t.index ["subnetwork_id"], name: "index_ipv6_networks_on_subnetwork_id"
  end

  create_table "network_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "dhcp", default: false, null: false
    t.boolean "auth", default: false, null: false
    t.boolean "managed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_network_categories_on_name", unique: true
  end

  create_table "network_connections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_interface_id", null: false
    t.bigint "subnetwork_id", null: false
    t.boolean "mac_address_randomization"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_interface_id"], name: "index_network_connections_on_network_interface_id"
    t.index ["subnetwork_id"], name: "index_network_connections_on_subnetwork_id"
  end

  create_table "network_interfaces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.string "name"
    t.integer "interface_type"
    t.string "mac_address"
    t.string "duid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["duid"], name: "index_network_interfaces_on_duid"
    t.index ["mac_address"], name: "index_network_interfaces_on_mac_address"
    t.index ["node_id"], name: "index_network_interfaces_on_node_id"
  end

  create_table "nodes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.timestamp "confirmed_at"
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "location_type"
    t.bigint "location_id"
    t.bigint "hardware_id"
    t.bigint "operating_system_id"
    t.bigint "security_software_id"
    t.index ["hardware_id"], name: "index_nodes_on_hardware_id"
    t.index ["location_type", "location_id"], name: "index_nodes_on_location_type_and_location_id"
    t.index ["name"], name: "index_nodes_on_name"
    t.index ["operating_system_id"], name: "index_nodes_on_operating_system_id"
    t.index ["owner_type", "owner_id"], name: "index_nodes_on_owner_type_and_owner_id"
    t.index ["security_software_id"], name: "index_nodes_on_security_software_id"
  end

  create_table "operating_systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "category"
    t.string "name"
    t.date "eol"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_operating_systems_on_name", unique: true
  end

  create_table "places", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "area"
    t.string "building"
    t.integer "floor"
    t.string "room"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area"], name: "index_places_on_area"
    t.index ["building"], name: "index_places_on_building"
    t.index ["room"], name: "index_places_on_room"
  end

  create_table "security_softwares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_security_softwares_on_name", unique: true
  end

  create_table "subnetwork_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "subnetwork_id", null: false
    t.bigint "user_id", null: false
    t.boolean "assignable"
    t.boolean "managable"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subnetwork_id"], name: "index_subnetwork_users_on_subnetwork_id"
    t.index ["user_id"], name: "index_subnetwork_users_on_user_id"
  end

  create_table "subnetworks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "network_category_id", null: false
    t.integer "vlan"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_subnetworks_on_name", unique: true
    t.index ["network_category_id"], name: "index_subnetworks_on_network_category_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "fullname"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0, null: false
    t.bigint "default_subnetwork_id"
    t.index ["default_subnetwork_id"], name: "index_users_on_default_subnetwork_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "version_associations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.text "object_changes", size: :long
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  add_foreign_key "ipv4_addresses", "network_connections"
  add_foreign_key "ipv4_networks", "subnetworks"
  add_foreign_key "ipv6_addresses", "network_connections"
  add_foreign_key "ipv6_networks", "subnetworks"
  add_foreign_key "network_connections", "network_interfaces"
  add_foreign_key "network_connections", "subnetworks"
  add_foreign_key "network_interfaces", "nodes"
  add_foreign_key "nodes", "hardwares"
  add_foreign_key "nodes", "operating_systems"
  add_foreign_key "nodes", "security_softwares"
  add_foreign_key "subnetwork_users", "subnetworks"
  add_foreign_key "subnetwork_users", "users"
  add_foreign_key "subnetworks", "network_categories"
  add_foreign_key "users", "subnetworks", column: "default_subnetwork_id"
end
