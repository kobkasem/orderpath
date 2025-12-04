# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source of truth for your database schema.

ActiveRecord::Schema[7.1].define(version: 20240101000009) do
  enable_extension "plpgsql"

  create_table "api_logs", force: :cascade do |t|
    t.bigint "order_id"
    t.string "api_type", null: false
    t.string "endpoint"
    t.string "method", default: "POST"
    t.jsonb "request_data"
    t.jsonb "response_data"
    t.integer "status_code"
    t.string "status", default: "pending"
    t.text "error_message"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "api_type"], name: "index_api_logs_on_order_id_and_api_type"
    t.index ["status"], name: "index_api_logs_on_status"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "api_key", null: false
    t.string "api_endpoint", null: false
    t.boolean "active", default: true
    t.jsonb "api_config", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_customers_on_api_key", unique: true
  end

  create_table "inventory_locations", force: :cascade do |t|
    t.bigint "sku_id", null: false
    t.string "location_type", null: false
    t.string "location_code"
    t.integer "quantity", default: 0
    t.integer "reserved_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku_id", "location_type"], name: "index_inventory_locations_on_sku_id_and_location_type"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "sku_id", null: false
    t.integer "quantity", null: false
    t.integer "quantity_from_robot", default: 0
    t.integer "quantity_from_bin", default: 0
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "order_number", null: false
    t.string "airway_bill_number"
    t.string "status", default: "pending"
    t.jsonb "order_data", default: {}
    t.text "error_message"
    t.integer "retry_count", default: 0
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "picking_slip_items", force: :cascade do |t|
    t.bigint "picking_slip_id", null: false
    t.bigint "order_item_id", null: false
    t.string "location_type", null: false
    t.string "location_code"
    t.integer "quantity", null: false
    t.integer "sequence", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["picking_slip_id", "sequence"], name: "index_picking_slip_items_on_picking_slip_id_and_sequence"
  end

  create_table "picking_slips", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "printer_id"
    t.string "slip_number", null: false
    t.string "status", default: "pending"
    t.text "slip_content"
    t.integer "print_attempts", default: 0
    t.datetime "printed_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slip_number"], name: "index_picking_slips_on_slip_number", unique: true
  end

  create_table "printers", force: :cascade do |t|
    t.string "name", null: false
    t.string "ip_address", null: false
    t.integer "port", default: 9100
    t.string "printer_type", default: "picking_slip"
    t.boolean "active", default: true
    t.jsonb "config", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_address"], name: "index_printers_on_ip_address"
  end

  create_table "skus", force: :cascade do |t|
    t.string "sku_code", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.string "model"
    t.integer "robot_threshold", default: 5
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku_code"], name: "index_skus_on_sku_code", unique: true
  end

  add_foreign_key "api_logs", "orders"
  add_foreign_key "inventory_locations", "skus"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "skus"
  add_foreign_key "orders", "customers"
  add_foreign_key "picking_slip_items", "order_items"
  add_foreign_key "picking_slip_items", "picking_slips"
  add_foreign_key "picking_slips", "orders"
  add_foreign_key "picking_slips", "printers"
end

