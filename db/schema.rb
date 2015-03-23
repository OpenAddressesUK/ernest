# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150227121613) do

  create_table "activities", force: true do |t|
    t.datetime "executed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "processing_script"
    t.string   "attribution"
  end

  create_table "addresses", force: true do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score",       limit: 24
  end

  create_table "addresses_tags", id: false, force: true do |t|
    t.integer  "address_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses_tags", ["address_id", "tag_id"], :name => "index_addresses_tags_on_address_id_and_tag_id"
  add_index "addresses_tags", ["address_id"], :name => "index_addresses_tags_on_address_id"
  add_index "addresses_tags", ["tag_id"], :name => "index_addresses_tags_on_tag_id"

  create_table "confidences", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "value",      limit: 24
    t.integer  "left_id"
    t.integer  "right_id"
  end

  create_table "derivations", force: true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "derivations", ["activity_id"], :name => "index_derivations_on_activity_id"

  create_table "sources", force: true do |t|
    t.string   "input"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
  end

  create_table "tag_types", force: true do |t|
    t.string   "label"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_types", ["id"], :name => "tag_type_id"

  create_table "tags", force: true do |t|
    t.string   "label"
    t.spatial  "point",       limit: {:type=>"point"},       null: false
    t.spatial  "line",        limit: {:type=>"line_string"}, null: false
    t.spatial  "area",        limit: {:type=>"geometry"},    null: false
    t.integer  "tag_type_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["area"], :name => "index_tags_on_area", :spatial => true
  add_index "tags", ["line"], :name => "index_tags_on_line", :spatial => true
  add_index "tags", ["point"], :name => "index_tags_on_point", :spatial => true

  create_table "users", force: true do |t|
    t.string "name"
    t.string "email"
    t.string "api_key"
  end

  create_table "validations", force: true do |t|
    t.float   "value",       limit: 24
    t.integer "activity_id"
    t.string  "reason"
  end

end
