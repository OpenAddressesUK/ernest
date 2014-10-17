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

ActiveRecord::Schema.define(version: 20141017155906) do

  create_table "activities", force: true do |t|
    t.datetime "executed_at"
  end

  create_table "addresses", force: true do |t|
    t.integer "activity_id"
  end

  create_table "addresses_tags", id: false, force: true do |t|
    t.integer "address_id"
    t.integer "tag_id"
  end

  create_table "derivations", force: true do |t|
    t.integer "entity_id"
    t.string  "entity_type"
    t.integer "activity_id"
  end

  create_table "sources", force: true do |t|
    t.string  "url"
    t.integer "activity_id"
  end

  create_table "tag_types", force: true do |t|
    t.string "label"
    t.string "description"
  end

  create_table "tags", force: true do |t|
    t.string  "label"
    t.spatial "point",       limit: {:type=>"point"},       null: false
    t.spatial "line",        limit: {:type=>"line_string"}, null: false
    t.spatial "area",        limit: {:type=>"geometry"},    null: false
    t.integer "tag_type_id"
    t.integer "activity_id"
  end

  add_index "tags", ["area"], :name => "index_tags_on_area", :spatial => true
  add_index "tags", ["line"], :name => "index_tags_on_line", :spatial => true
  add_index "tags", ["point"], :name => "index_tags_on_point", :spatial => true

end
