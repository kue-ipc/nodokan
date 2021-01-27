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

ActiveRecord::Schema.define(version: 2020_09_25_011323) do

  create_table "confirmations", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "node_id", null: false
    t.bigint "security_software_id"
    t.integer "existence", null: false
    t.integer "content", null: false
    t.integer "os_update", null: false
    t.integer "app_upadte", null: false
    t.integer "security_update", null: false
    t.integer "security_scan", null: false
    t.timestamp "confirmed_at", default: -> { "current_timestamp()" }, null: false
    t.timestamp "expiration", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["node_id"], name: "index_confirmations_on_node_id", unique: true
    t.index ["security_software_id"], name: "index_confirmations_on_security_software_id"
    t.index ["user_id"], name: "index_confirmations_on_user_id"
  end

  create_table "hardwares", charset: "utf8mb4", force: :cascade do |t|
    t.integer "device_type", null: false
    t.string "maker", default: "", null: false
    t.string "product_name", default: "", null: false
    t.string "model_number", default: "", null: false
    t.boolean "confirmed", default: false, null: false
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["device_type", "maker", "product_name", "model_number"], name: "hardware_model", unique: true
    t.index ["maker"], name: "index_hardwares_on_maker"
    t.index ["model_number"], name: "index_hardwares_on_model_number"
    t.index ["product_name"], name: "index_hardwares_on_product_name"
  end

  create_table "ip6_pools", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "network_id", null: false
    t.integer "ip6_config", null: false
    t.string "first6_address", limit: 40, null: false
    t.string "last6_address", limit: 40, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_id"], name: "index_ip6_pools_on_network_id"
  end

  create_table "ip_pools", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "network_id", null: false
    t.integer "ip_config", null: false
    t.string "first_address", limit: 16, null: false
    t.string "last_address", limit: 16, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["network_id"], name: "index_ip_pools_on_network_id"
  end

  create_table "network_users", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "network_id", null: false
    t.bigint "user_id", null: false
    t.boolean "available", default: false, null: false
    t.boolean "managable", default: false, null: false
    t.boolean "assigned", default: false, null: false
    t.index ["network_id", "user_id"], name: "index_network_users_on_network_id_and_user_id", unique: true
    t.index ["network_id"], name: "index_network_users_on_network_id"
    t.index ["user_id"], name: "index_network_users_on_user_id"
  end

  create_table "networks", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.integer "vlan"
    t.boolean "dhcp", default: false, null: false
    t.boolean "auth", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.string "ip_address", limit: 16
    t.string "ip_mask", limit: 16
    t.string "ip_gateway", limit: 16
    t.string "ip6_address", limit: 40
    t.integer "ip6_prefix"
    t.string "ip6_gateway", limit: 40
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_networks_on_name", unique: true
  end

  create_table "nics", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.bigint "network_id"
    t.string "name"
    t.integer "interface_type", null: false
    t.string "mac_address", limit: 18
    t.string "duid"
    t.integer "ip_config"
    t.string "ip_address", limit: 16
    t.integer "ip6_config"
    t.string "ip6_address", limit: 40
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["duid"], name: "index_nics_on_duid"
    t.index ["ip6_address"], name: "index_nics_on_ip6_address"
    t.index ["ip_address"], name: "index_nics_on_ip_address"
    t.index ["mac_address"], name: "index_nics_on_mac_address"
    t.index ["network_id"], name: "index_nics_on_network_id"
    t.index ["node_id"], name: "index_nics_on_node_id"
  end

  create_table "nodes", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "hostname"
    t.string "domain"
    t.bigint "place_id"
    t.bigint "hardware_id"
    t.bigint "operating_system_id"
    t.text "note"
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

  create_table "operating_systems", charset: "utf8mb4", force: :cascade do |t|
    t.integer "os_category", null: false
    t.string "name", null: false
    t.date "eol"
    t.boolean "approved", default: false, null: false
    t.boolean "confirmed", default: false, null: false
    t.text "description"
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_operating_systems_on_name", unique: true
    t.index ["os_category"], name: "index_operating_systems_on_os_category"
  end

  create_table "places", charset: "utf8mb4", force: :cascade do |t|
    t.string "area", default: "", null: false
    t.string "building", default: "", null: false
    t.integer "floor", default: 0, null: false
    t.string "room", default: "", null: false
    t.boolean "confirmed", default: false, null: false
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area", "building", "floor", "room"], name: "index_places_on_area_and_building_and_floor_and_room", unique: true
    t.index ["area"], name: "index_places_on_area"
    t.index ["building"], name: "index_places_on_building"
    t.index ["room"], name: "index_places_on_room"
  end

  create_table "security_softwares", charset: "utf8mb4", force: :cascade do |t|
    t.integer "installation_method", null: false
    t.integer "os_category", null: false
    t.string "name", null: false
    t.boolean "approved", default: false, null: false
    t.boolean "confirmed", default: false, null: false
    t.text "description"
    t.integer "confirmations_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["installation_method", "os_category", "name"], name: "security_softoware_name", unique: true
    t.index ["installation_method"], name: "index_security_softwares_on_installation_method"
    t.index ["name"], name: "index_security_softwares_on_name"
    t.index ["os_category"], name: "index_security_softwares_on_os_category"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "fullname"
    t.integer "role", default: 0, null: false
    t.boolean "deleted", default: false, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "nodes_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "version_associations", charset: "utf8mb4", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.string "foreign_type"
    t.index ["foreign_key_name", "foreign_key_id", "foreign_type"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", charset: "utf8mb4", force: :cascade do |t|
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
  add_foreign_key "ip6_pools", "networks"
  add_foreign_key "ip_pools", "networks"
  add_foreign_key "network_users", "networks"
  add_foreign_key "network_users", "users"
  add_foreign_key "nics", "networks"
  add_foreign_key "nics", "nodes"
  add_foreign_key "nodes", "hardwares"
  add_foreign_key "nodes", "operating_systems"
  add_foreign_key "nodes", "places"
  add_foreign_key "nodes", "users"
end
