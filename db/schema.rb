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

ActiveRecord::Schema.define(version: 2020_09_24_065048) do

  create_table "confirmations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "node_id", null: false
    t.bigint "security_software_id"
    t.integer "existence", null: false
    t.integer "content", null: false
    t.integer "os_update", null: false
    t.integer "ms_upadte", null: false
    t.integer "store_update", null: false
    t.integer "soft_update", null: false
    t.integer "security_update", null: false
    t.integer "security_scan", null: false
    t.date "updated_date", null: false
    t.boolean "approved"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["node_id"], name: "index_confirmations_on_node_id"
    t.index ["security_software_id"], name: "index_confirmations_on_security_software_id"
    t.index ["user_id"], name: "index_confirmations_on_user_id"
  end

  create_table "hardwares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "device_type", null: false
    t.string "maker", default: "", null: false
    t.string "product_name", default: "", null: false
    t.string "model_number", default: "", null: false
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_type", "maker", "product_name", "model_number"], name: "hardware_model", unique: true
    t.index ["maker"], name: "index_hardwares_on_maker"
    t.index ["model_number"], name: "index_hardwares_on_model_number"
    t.index ["product_name"], name: "index_hardwares_on_product_name"
  end

  create_table "ip_addresses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_connection_id", null: false
    t.bigint "ip_pool_id"
    t.integer "family", default: 2, null: false
    t.integer "config", null: false
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address"], name: "index_ip_addresses_on_address"
    t.index ["ip_pool_id"], name: "index_ip_addresses_on_ip_pool_id"
    t.index ["network_connection_id"], name: "index_ip_addresses_on_network_connection_id"
  end

  create_table "ip_networks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "subnetwork_id", null: false
    t.integer "family", default: 2, null: false
    t.string "address", null: false
    t.string "gateway"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["address"], name: "index_ip_networks_on_address"
    t.index ["subnetwork_id"], name: "index_ip_networks_on_subnetwork_id"
  end

  create_table "ip_pools", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "ip_network_id", null: false
    t.integer "family", default: 2, null: false
    t.integer "config", null: false
    t.string "first", null: false
    t.string "last", null: false
    t.integer "ip_address_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip_network_id"], name: "index_ip_pools_on_ip_network_id"
  end

  create_table "network_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "dhcp", default: false, null: false
    t.boolean "auth", default: false, null: false
    t.boolean "global", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_network_categories_on_name", unique: true
  end

  create_table "network_connections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_interface_id", null: false
    t.bigint "subnetwork_id", null: false
    t.boolean "mac_address_randomization", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_interface_id"], name: "index_network_connections_on_network_interface_id"
    t.index ["subnetwork_id"], name: "index_network_connections_on_subnetwork_id"
  end

  create_table "network_interfaces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.integer "interface_type", default: 0, null: false
    t.string "name"
    t.string "mac_address"
    t.string "duid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["duid"], name: "index_network_interfaces_on_duid"
    t.index ["mac_address"], name: "index_network_interfaces_on_mac_address"
    t.index ["node_id"], name: "index_network_interfaces_on_node_id"
  end

  create_table "network_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "network_id", null: false
    t.bigint "user_id", null: false
    t.boolean "assignable", default: false, null: false
    t.boolean "managable", default: false, null: false
    t.boolean "assigned", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_id", "user_id"], name: "index_network_users_on_network_id_and_user_id", unique: true
    t.index ["network_id"], name: "index_network_users_on_network_id"
    t.index ["user_id"], name: "index_network_users_on_user_id"
  end

  create_table "networks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.integer "vlan"
    t.boolean "dhcp"
    t.boolean "auth"
    t.boolean "closed"
    t.binary "ip_address"
    t.integer "ip_prefix"
    t.binary "ip_gateway"
    t.binary "ip6_address"
    t.integer "ip6_prefix"
    t.binary "ip6_gateway"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_networks_on_name", unique: true
  end

  create_table "nics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.bigint "network_id", null: false
    t.string "name"
    t.binary "mac_address"
    t.binary "duid"
    t.integer "ip_config"
    t.binary "ip_address"
    t.integer "ip6_config"
    t.binary "ip6_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_id"], name: "index_nics_on_network_id"
    t.index ["node_id"], name: "index_nics_on_node_id"
  end

  create_table "nodes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "hostname"
    t.string "domain"
    t.bigint "place_id"
    t.bigint "hardware_id"
    t.bigint "operating_system_id"
    t.text "note"
    t.timestamp "confirmed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain"], name: "index_nodes_on_domain"
    t.index ["hardware_id"], name: "index_nodes_on_hardware_id"
    t.index ["hostname", "domain"], name: "fqdn", unique: true
    t.index ["hostname"], name: "index_nodes_on_hostname"
    t.index ["name"], name: "index_nodes_on_name"
    t.index ["operating_system_id"], name: "index_nodes_on_operating_system_id"
    t.index ["place_id"], name: "index_nodes_on_place_id"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "operating_systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "os_category", null: false
    t.string "name", null: false
    t.date "eol"
    t.text "description"
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_operating_systems_on_name", unique: true
    t.index ["os_category"], name: "index_operating_systems_on_os_category"
  end

  create_table "places", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "area", default: "", null: false
    t.string "building", default: "", null: false
    t.integer "floor", default: 0, null: false
    t.string "room", default: "", null: false
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area", "building", "floor", "room"], name: "index_places_on_area_and_building_and_floor_and_room", unique: true
    t.index ["area"], name: "index_places_on_area"
    t.index ["building"], name: "index_places_on_building"
    t.index ["room"], name: "index_places_on_room"
  end

  create_table "security_softwares", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "state", null: false
    t.integer "os_category", null: false
    t.string "name", null: false
    t.boolean "approved"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_security_softwares_on_name"
    t.index ["state", "os_category", "name"], name: "index_security_softwares_on_state_and_os_category_and_name", unique: true
    t.index ["state", "os_category"], name: "index_security_softwares_on_state_and_os_category"
  end

  create_table "subnetwork_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "subnetwork_id", null: false
    t.bigint "user_id", null: false
    t.boolean "assignable", default: false, null: false
    t.boolean "managable", default: false, null: false
    t.boolean "default", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subnetwork_id"], name: "index_subnetwork_users_on_subnetwork_id"
    t.index ["user_id"], name: "index_subnetwork_users_on_user_id"
  end

  create_table "subnetworks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "network_category_id", null: false
    t.integer "vlan", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_subnetworks_on_name", unique: true
    t.index ["network_category_id"], name: "index_subnetworks_on_network_category_id"
    t.index ["vlan"], name: "index_subnetworks_on_vlan", unique: true
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "fullname"
    t.integer "role", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  add_foreign_key "confirmations", "nodes"
  add_foreign_key "confirmations", "security_softwares"
  add_foreign_key "confirmations", "users"
  add_foreign_key "ip_addresses", "ip_pools"
  add_foreign_key "ip_addresses", "network_connections"
  add_foreign_key "ip_networks", "subnetworks"
  add_foreign_key "ip_pools", "ip_networks"
  add_foreign_key "network_connections", "network_interfaces"
  add_foreign_key "network_connections", "subnetworks"
  add_foreign_key "network_interfaces", "nodes"
  add_foreign_key "network_users", "networks"
  add_foreign_key "network_users", "users"
  add_foreign_key "nics", "networks"
  add_foreign_key "nics", "nodes"
  add_foreign_key "nodes", "hardwares"
  add_foreign_key "nodes", "operating_systems"
  add_foreign_key "nodes", "places"
  add_foreign_key "nodes", "users"
  add_foreign_key "subnetwork_users", "subnetworks"
  add_foreign_key "subnetwork_users", "users"
  add_foreign_key "subnetworks", "network_categories"
end
