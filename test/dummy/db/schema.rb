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

ActiveRecord::Schema.define(version: 2021_08_25_195251) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "collections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "visibility"
    t.bigint "owner_id", null: false
    t.datetime "record_created_at"
    t.string "hydra_noid"
    t.datetime "date_ingested"
    t.string "title", null: false
    t.string "fedora3_uuid"
    t.string "depositor"
    t.uuid "community_id"
    t.text "description"
    t.json "creators", array: true
    t.boolean "restricted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_collections_on_owner_id"
  end

  create_table "communities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "visibility"
    t.bigint "owner_id", null: false
    t.datetime "record_created_at"
    t.string "hydra_noid"
    t.datetime "date_ingested"
    t.string "title", null: false
    t.string "fedora3_uuid"
    t.string "depositor"
    t.text "description"
    t.json "creators", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_communities_on_owner_id"
  end


  create_table "items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "visibility"
    t.bigint "owner_id", null: false
    t.datetime "record_created_at"
    t.string "hydra_noid"
    t.datetime "date_ingested", null: false
    t.string "title", null: false
    t.string "fedora3_uuid"
    t.string "depositor"
    t.string "alternative_title"
    t.string "doi"
    t.datetime "embargo_end_date"
    t.string "visibility_after_embargo"
    t.string "fedora3_handle"
    t.string "ingest_batch"
    t.string "northern_north_america_filename"
    t.string "northern_north_america_item_id"
    t.text "rights"
    t.integer "sort_year"
    t.json "embargo_history", array: true
    t.json "is_version_of", array: true
    t.json "member_of_paths", null: false, array: true
    t.json "creators", array: true
    t.json "contributors", array: true
    t.string "created"
    t.json "temporal_subjects", array: true
    t.json "spatial_subjects", array: true
    t.text "description"
    t.string "publisher"
    t.json "languages", array: true
    t.text "license"
    t.string "item_type"
    t.string "source"
    t.string "related_link"
    t.json "publication_status", array: true
    t.bigint "logo_id"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "subject", array: true
    t.bigint "batch_ingest_id"
    t.index ["batch_ingest_id"], name: "index_items_on_batch_ingest_id"
    t.index ["logo_id"], name: "index_items_on_logo_id"
    t.index ["owner_id"], name: "index_items_on_owner_id"
  end

  create_table "rdf_annotations", force: :cascade do |t|
    t.string "table"
    t.string "column"
    t.string "predicate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "theses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "visibility"
    t.bigint "owner_id", null: false
    t.datetime "record_created_at"
    t.string "hydra_noid"
    t.datetime "date_ingested", null: false
    t.string "title", null: false
    t.string "fedora3_uuid"
    t.string "depositor"
    t.string "alternative_title"
    t.string "doi"
    t.datetime "embargo_end_date"
    t.string "visibility_after_embargo"
    t.string "fedora3_handle"
    t.string "ingest_batch"
    t.string "northern_north_america_filename"
    t.string "northern_north_america_item_id"
    t.text "rights"
    t.integer "sort_year"
    t.json "embargo_history", array: true
    t.json "is_version_of", array: true
    t.json "member_of_paths", null: false, array: true
    t.text "abstract"
    t.string "language"
    t.datetime "date_accepted"
    t.datetime "date_submitted"
    t.string "degree"
    t.string "institution"
    t.string "dissertant"
    t.string "graduation_date"
    t.string "thesis_level"
    t.string "proquest"
    t.string "unicorn"
    t.string "specialization"
    t.json "departments", array: true
    t.json "supervisors", array: true
    t.json "committee_members", array: true
    t.bigint "logo_id"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "subject", array: true
    t.index ["logo_id"], name: "index_theses_on_logo_id"
    t.index ["owner_id"], name: "index_theses_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.boolean "admin", default: false, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "suspended", default: false, null: false
    t.datetime "previous_sign_in_at"
    t.string "previous_sign_in_ip"
    t.datetime "last_seen_at"
    t.string "last_seen_ip"
    t.string "api_key_digest"
    t.boolean "system", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "collections", "users", column: "owner_id"
  add_foreign_key "communities", "users", column: "owner_id"
  add_foreign_key "items", "users", column: "owner_id"
  add_foreign_key "theses", "users", column: "owner_id"
end
