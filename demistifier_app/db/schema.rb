# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_29_111748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.bigint "institution_program_language_id"
    t.bigint "child_id"
    t.date "registered_date"
    t.date "desirable_start_date"
    t.boolean "priority_5years_old"
    t.boolean "priority_commission"
    t.boolean "priority_sibling"
    t.boolean "priority_parent_local"
    t.boolean "priority_child_local"
    t.boolean "private_fin_local"
    t.boolean "nanny_fin_local"
    t.boolean "choose_not_to_receive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "riga_queue_position"
    t.integer "real_queue_position"
    t.integer "sort_index"
    t.index ["child_id"], name: "index_applications_on_child_id"
    t.index ["institution_program_language_id"], name: "index_applications_on_institution_program_language_id"
  end

  create_table "children", force: :cascade do |t|
    t.string "child_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institution_program_languages", force: :cascade do |t|
    t.bigint "institution_id"
    t.string "starting_age"
    t.string "language"
    t.string "language_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "queue_size"
    t.index ["institution_id"], name: "index_institution_program_languages_on_institution_id"
  end

  create_table "institutions", force: :cascade do |t|
    t.string "name"
    t.text "alternate_names"
    t.string "reg_nr"
    t.string "lr_izm_code"
    t.string "address"
    t.string "institution_type"
    t.string "email"
    t.string "url"
    t.float "lat"
    t.float "lon"
    t.integer "institution_id_source"
    t.bigint "region_id"
    t.datetime "created_at", default: -> { "('now'::text)::date" }, null: false
    t.datetime "updated_at", default: -> { "('now'::text)::date" }, null: false
    t.index ["region_id"], name: "index_institutions_on_region_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", default: -> { "('now'::text)::date" }, null: false
    t.datetime "updated_at", default: -> { "('now'::text)::date" }, null: false
  end

  create_table "statistic_measures", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statistics", force: :cascade do |t|
    t.bigint "institution_id"
    t.bigint "region_id"
    t.bigint "statistic_measure_id"
    t.integer "value"
    t.date "value_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "institution_program_language_id"
    t.integer "year"
    t.index ["institution_id"], name: "index_statistics_on_institution_id"
    t.index ["institution_program_language_id"], name: "index_statistics_on_institution_program_language_id"
    t.index ["region_id"], name: "index_statistics_on_region_id"
    t.index ["statistic_measure_id"], name: "index_statistics_on_statistic_measure_id"
  end

  add_foreign_key "applications", "children"
  add_foreign_key "applications", "institution_program_languages"
  add_foreign_key "institution_program_languages", "institutions"
  add_foreign_key "institutions", "regions"
  add_foreign_key "statistics", "institution_program_languages"
  add_foreign_key "statistics", "institutions"
  add_foreign_key "statistics", "regions"
  add_foreign_key "statistics", "statistic_measures"
end
