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

ActiveRecord::Schema[8.1].define(version: 2025_11_12_055338) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "event_times", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.bigint "event_id", null: false
    t.integer "position", default: 0
    t.datetime "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "position"], name: "index_event_times_on_event_id_and_position"
    t.index ["event_id"], name: "index_event_times_on_event_id"
  end

  create_table "event_versions", force: :cascade do |t|
    t.string "action_type"
    t.text "change_summary"
    t.string "changed_by"
    t.datetime "created_at", null: false
    t.text "event_description"
    t.bigint "event_id", null: false
    t.string "event_image_url"
    t.string "event_location"
    t.string "event_name"
    t.string "event_registration_link"
    t.json "event_times_snapshot"
    t.datetime "updated_at", null: false
    t.datetime "version_timestamp"
    t.index ["event_id", "created_at"], name: "index_event_versions_on_event_id_and_created_at"
    t.index ["event_id"], name: "index_event_versions_on_event_id"
    t.index ["version_timestamp"], name: "index_event_versions_on_version_timestamp"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "location", null: false
    t.string "name", null: false
    t.boolean "published", default: true
    t.string "registration_link"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "event_times", "events"
  add_foreign_key "event_versions", "events"
  add_foreign_key "sessions", "users"
end
