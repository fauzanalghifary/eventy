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

ActiveRecord::Schema[8.0].define(version: 2026_07_02_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_items", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "ticket_type_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "ticket_type_id"], name: "index_booking_items_on_booking_id_and_ticket_type_id"
    t.index ["booking_id"], name: "index_booking_items_on_booking_id"
    t.index ["ticket_type_id"], name: "index_booking_items_on_ticket_type_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.date "booking_date", null: false
    t.string "confirmation_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_code"], name: "index_bookings_on_confirmation_code", unique: true
    t.index ["event_id", "booking_date"], name: "index_bookings_on_event_id_and_booking_date"
    t.index ["event_id"], name: "index_bookings_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "ticket_types", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "name"], name: "index_ticket_types_on_event_id_and_name", unique: true
    t.index ["event_id"], name: "index_ticket_types_on_event_id"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "booking_items", "bookings"
  add_foreign_key "booking_items", "ticket_types"
  add_foreign_key "bookings", "events"
  add_foreign_key "events", "venues"
  add_foreign_key "ticket_types", "events"
end
