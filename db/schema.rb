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

ActiveRecord::Schema.define(version: 20141016103946) do

  create_table "addresses", force: true do |t|
  end

  create_table "addresses_geo_objects", id: false, force: true do |t|
    t.integer "address_id"
    t.integer "geo_object_id"
  end

  create_table "geo_nestings", id: false, force: true do |t|
    t.integer "container_id"
    t.integer "containee_id"
  end

  create_table "geo_objects", force: true do |t|
    t.string  "label"
    t.spatial "point",  limit: {:type=>"point"},       null: false
    t.spatial "line",   limit: {:type=>"line_string"}, null: false
    t.spatial "area",   limit: {:type=>"geometry"},    null: false
    t.integer "tag_id"
  end

  add_index "geo_objects", ["area"], :name => "index_geo_objects_on_area", :spatial => true
  add_index "geo_objects", ["line"], :name => "index_geo_objects_on_line", :spatial => true
  add_index "geo_objects", ["point"], :name => "index_geo_objects_on_point", :spatial => true

  create_table "tags", force: true do |t|
    t.string "label"
    t.string "description"
  end

end
