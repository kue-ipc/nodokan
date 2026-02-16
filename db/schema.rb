# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_16_045835) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "auth", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.boolean "manage", default: false, null: false
    t.bigint "network_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "use", default: false, null: false
    t.bigint "user_id", null: false
    t.index ["network_id"], name: "index_assignments_on_network_id"
    t.index ["user_id", "network_id"], name: "index_assignments_on_user_id_and_network_id", unique: true
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "bulks", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "failure", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "number", default: 0, null: false
    t.integer "status", null: false
    t.integer "success", default: 0, null: false
    t.string "target", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_bulks_on_user_id"
  end

  create_table "confirmations", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "app_update", limit: 1, default: -1, null: false
    t.boolean "approved", default: false, null: false
    t.timestamp "confirmed_at", default: -> { "current_timestamp() ON UPDATE current_timestamp()" }, null: false
    t.integer "content", limit: 1, default: -1, null: false
    t.datetime "created_at", null: false
    t.integer "existence", limit: 1, default: -1, null: false
    t.bigint "node_id", null: false
    t.integer "os_update", limit: 1, default: -1, null: false
    t.integer "security_hardware", default: -1, null: false
    t.integer "security_scan", limit: 1, default: -1, null: false
    t.bigint "security_software_id"
    t.integer "security_update", limit: 1, default: -1, null: false
    t.integer "software", limit: 1, default: -1, null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_confirmations_on_node_id", unique: true
    t.index ["security_software_id"], name: "index_confirmations_on_security_software_id"
  end

  create_table "device_types", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.boolean "locked", default: false, null: false
    t.string "name", null: false
    t.integer "order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_device_types_on_name", unique: true
  end

  create_table "hardwares", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "device_type_id"
    t.string "maker", default: "", null: false
    t.string "model_number", default: "", null: false
    t.integer "nodes_count", default: 0, null: false
    t.string "product_name", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["device_type_id", "maker", "product_name", "model_number"], name: "index_hardwares_on_hardware_model", unique: true
    t.index ["device_type_id"], name: "index_hardwares_on_device_type_id"
    t.index ["maker"], name: "index_hardwares_on_maker"
    t.index ["model_number"], name: "index_hardwares_on_model_number"
    t.index ["product_name"], name: "index_hardwares_on_product_name"
  end

  create_table "ipv4_arps", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "begin_at"
    t.datetime "created_at", null: false
    t.datetime "end_at", precision: nil, null: false
    t.binary "ipv4_data", limit: 4, null: false
    t.binary "mac_address_data", limit: 6, null: false
    t.datetime "updated_at", null: false
    t.index ["ipv4_data"], name: "index_ipv4_arps_on_ipv4_data"
    t.index ["mac_address_data"], name: "index_ipv4_arps_on_mac_address_data"
  end

  create_table "ipv4_pools", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ipv4_config", limit: 1, null: false
    t.binary "ipv4_first_data", limit: 4, null: false
    t.binary "ipv4_last_data", limit: 4, null: false
    t.bigint "network_id", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_ipv4_pools_on_network_id"
  end

  create_table "ipv6_neighbors", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "begin_at"
    t.datetime "created_at", null: false
    t.datetime "end_at", precision: nil, null: false
    t.binary "ipv6_data", limit: 16, null: false
    t.binary "mac_address_data", limit: 6, null: false
    t.datetime "updated_at", null: false
    t.index ["ipv6_data"], name: "index_ipv6_neighbors_on_ipv6_data"
    t.index ["mac_address_data"], name: "index_ipv6_neighbors_on_mac_address_data"
  end

  create_table "ipv6_pools", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ipv6_config", limit: 1, null: false
    t.binary "ipv6_first_data", limit: 16, null: false
    t.binary "ipv6_last_data", limit: 16, null: false
    t.bigint "network_id", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_ipv6_pools_on_network_id"
  end

  create_table "logical_compositions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.datetime "created_at", null: false
    t.bigint "node_id", null: false
    t.datetime "updated_at", null: false
    t.index ["component_id"], name: "index_logical_compositions_on_component_id"
    t.index ["node_id"], name: "index_logical_compositions_on_node_id"
  end

  create_table "networks", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "assignments_count", default: 0, null: false
    t.boolean "auth", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "dhcp", default: false, null: false
    t.boolean "disabled", default: false, null: false
    t.string "domain"
    t.text "domain_search_data", size: :long, collation: "utf8mb4_bin"
    t.text "ipv4_dns_servers_data", size: :long, collation: "utf8mb4_bin"
    t.binary "ipv4_gateway_data", limit: 4
    t.binary "ipv4_network_data", limit: 4
    t.integer "ipv4_prefix_length", limit: 1, default: 0, null: false
    t.text "ipv6_dns_servers_data", size: :long, collation: "utf8mb4_bin"
    t.binary "ipv6_gateway_data", limit: 16
    t.binary "ipv6_network_data", limit: 16
    t.integer "ipv6_prefix_length", limit: 1, default: 0, null: false
    t.boolean "locked", default: false, null: false
    t.string "name", null: false
    t.integer "nics_count", default: 0, null: false
    t.text "note"
    t.integer "ra", default: -1, null: false
    t.boolean "unverifiable", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "vlan", limit: 2
    t.index ["ipv4_network_data"], name: "index_networks_on_ipv4_network_data", unique: true
    t.index ["ipv6_network_data"], name: "index_networks_on_ipv6_network_data", unique: true
    t.index ["name"], name: "index_networks_on_name", unique: true
    t.index ["vlan"], name: "index_networks_on_vlan", unique: true
    t.check_constraint "json_valid(`domain_search_data`)", name: "domain_search_data"
    t.check_constraint "json_valid(`ipv4_dns_servers_data`)", name: "ipv4_dns_servers_data"
    t.check_constraint "json_valid(`ipv6_dns_servers_data`)", name: "ipv6_dns_servers_data"
  end

  create_table "nics", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "auth", default: false, null: false
    t.datetime "auth_at", precision: nil
    t.datetime "created_at", null: false
    t.integer "interface_type", limit: 1, null: false
    t.integer "ipv4_config", limit: 1, default: -1, null: false
    t.binary "ipv4_data", limit: 4
    t.datetime "ipv4_leased_at", precision: nil
    t.datetime "ipv4_resolved_at", precision: nil
    t.integer "ipv6_config", limit: 1, default: -1, null: false
    t.binary "ipv6_data", limit: 16
    t.datetime "ipv6_discovered_at", precision: nil
    t.datetime "ipv6_leased_at", precision: nil
    t.boolean "locked", default: false, null: false
    t.binary "mac_address_data", limit: 6
    t.string "name"
    t.bigint "network_id"
    t.bigint "node_id", null: false
    t.integer "number", limit: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["ipv4_data"], name: "index_nics_on_ipv4_data", unique: true
    t.index ["ipv6_data"], name: "index_nics_on_ipv6_data", unique: true
    t.index ["mac_address_data"], name: "index_nics_on_mac_address_data"
    t.index ["network_id", "mac_address_data"], name: "index_nics_on_network_id_and_mac_address_data", unique: true
    t.index ["network_id"], name: "index_nics_on_network_id"
    t.index ["node_id", "number"], name: "index_nics_on_node_id_and_number", unique: true
    t.index ["node_id"], name: "index_nics_on_node_id"
  end

  create_table "nodes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "disabled", default: false, null: false
    t.boolean "dns", default: false, null: false
    t.string "domain"
    t.binary "duid_data", limit: 130
    t.timestamp "execution_at"
    t.bigint "hardware_id"
    t.bigint "host_id"
    t.string "hostname"
    t.string "name", null: false
    t.integer "nics_count", default: 0, null: false
    t.integer "node_type", default: 0, null: false
    t.text "note"
    t.integer "notice", limit: 1, default: 0, null: false
    t.timestamp "noticed_at"
    t.bigint "operating_system_id"
    t.boolean "permanent", default: false, null: false
    t.bigint "place_id"
    t.boolean "public", default: false, null: false
    t.boolean "specific", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["duid_data"], name: "index_nodes_on_duid_data", unique: true
    t.index ["hardware_id"], name: "index_nodes_on_hardware_id"
    t.index ["host_id"], name: "index_nodes_on_host_id"
    t.index ["hostname", "domain"], name: "{:name=>:index_nodes_on_hostname_and_domain}", unique: true
    t.index ["operating_system_id"], name: "index_nodes_on_operating_system_id"
    t.index ["place_id"], name: "index_nodes_on_place_id"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "operating_systems", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "eol"
    t.string "name", null: false
    t.integer "nodes_count", default: 0, null: false
    t.bigint "os_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_operating_systems_on_name", unique: true
    t.index ["os_category_id"], name: "index_operating_systems_on_os_category_id"
  end

  create_table "os_categories", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.boolean "locked", default: false, null: false
    t.string "name", null: false
    t.integer "order", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_os_categories_on_name", unique: true
  end

  create_table "places", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "area", default: "", null: false
    t.string "building", default: "", null: false
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "floor", limit: 2, default: 0, null: false
    t.integer "nodes_count", default: 0, null: false
    t.string "room", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["area", "building", "floor", "room"], name: "index_places_on_area_and_building_and_floor_and_room", unique: true
    t.index ["area"], name: "index_places_on_area"
    t.index ["building"], name: "index_places_on_building"
    t.index ["floor"], name: "index_places_on_floor"
    t.index ["room"], name: "index_places_on_room"
  end

  create_table "security_softwares", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "approved", default: false, null: false
    t.integer "confirmations_count", default: 0, null: false
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "installation_method", limit: 1, null: false
    t.string "name", null: false
    t.bigint "os_category_id", null: false
    t.datetime "updated_at", null: false
    t.index ["installation_method"], name: "index_security_softwares_on_installation_method"
    t.index ["name"], name: "index_security_softwares_on_name"
    t.index ["os_category_id", "installation_method", "name"], name: "index_security_softwares_on_security_softoware_name", unique: true
    t.index ["os_category_id"], name: "index_security_softwares_on_os_category_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "assignments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "deleted", default: false, null: false
    t.string "email", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "fullname"
    t.integer "limit"
    t.datetime "locked_at", precision: nil
    t.integer "nodes_count", default: 0, null: false
    t.datetime "remember_created_at", precision: nil
    t.string "remember_token"
    t.integer "role", limit: 1, default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "version_associations", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "foreign_key_id"
    t.string "foreign_key_name", null: false
    t.string "foreign_type"
    t.integer "version_id"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object", size: :long
    t.text "object_changes", size: :long
    t.integer "transaction_id"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "networks"
  add_foreign_key "assignments", "users"
  add_foreign_key "bulks", "users"
  add_foreign_key "confirmations", "nodes"
  add_foreign_key "confirmations", "security_softwares"
  add_foreign_key "hardwares", "device_types"
  add_foreign_key "ipv4_pools", "networks"
  add_foreign_key "ipv6_pools", "networks"
  add_foreign_key "logical_compositions", "nodes"
  add_foreign_key "logical_compositions", "nodes", column: "component_id"
  add_foreign_key "nics", "networks"
  add_foreign_key "nics", "nodes"
  add_foreign_key "nodes", "hardwares"
  add_foreign_key "nodes", "nodes", column: "host_id"
  add_foreign_key "nodes", "operating_systems"
  add_foreign_key "nodes", "places"
  add_foreign_key "nodes", "users"
  add_foreign_key "operating_systems", "os_categories"
  add_foreign_key "security_softwares", "os_categories"
end
