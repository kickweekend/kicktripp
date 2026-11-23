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

ActiveRecord::Schema[8.1].define(version: 2026_11_23_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.bigint "place_id"
    t.string "title", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.text "notes"
    t.string "status", default: "planned", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_activities_on_place_id"
    t.index ["trip_id"], name: "index_activities_on_trip_id"
    t.check_constraint "ends_at >= starts_at", name: "activity_dates"
    t.check_constraint "status::text = ANY (ARRAY['planned'::character varying::text, 'completed'::character varying::text, 'cancelled'::character varying::text])", name: "activity_status"
  end

  create_table "destinations", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.string "country", null: false
    t.string "city", null: false
    t.date "arrival_on", null: false
    t.date "departure_on", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_destinations_on_trip_id"
    t.check_constraint "departure_on >= arrival_on AND \"position\" >= 0", name: "destination_dates_position"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "trip_id", null: false
    t.bigint "activity_id"
    t.string "title", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.string "currency", null: false
    t.date "spent_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_expenses_on_activity_id"
    t.index ["trip_id"], name: "index_expenses_on_trip_id"
    t.check_constraint "amount >= 0::numeric", name: "expense_amount"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "activity_id", null: false
    t.boolean "read", default: false, null: false
    t.boolean "invited", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_participations_on_activity_id"
    t.index ["user_id", "activity_id"], name: "index_participations_on_user_id_and_activity_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "places", force: :cascade do |t|
    t.bigint "destination_id", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.string "address"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_places_on_destination_id"
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.decimal "budget_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.string "currency", default: "RUB", null: false
    t.string "time_zone", default: "UTC", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
    t.check_constraint "budget_amount >= 0::numeric", name: "trip_budget"
    t.check_constraint "ends_on >= starts_on", name: "trip_dates"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "interests", default: "", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "users_email_unique", unique: true
  end

  add_foreign_key "activities", "places"
  add_foreign_key "activities", "trips"
  add_foreign_key "destinations", "trips"
  add_foreign_key "expenses", "activities"
  add_foreign_key "expenses", "trips"
  add_foreign_key "participations", "activities"
  add_foreign_key "participations", "users"
  add_foreign_key "places", "destinations"
  add_foreign_key "trips", "users"
end
