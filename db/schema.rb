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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111204172529) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "kupongid", :force => true do |t|
    t.integer  "kupongid_id",  :null => false
    t.integer  "category_id"
    t.string   "provider"
    t.string   "url",          :null => false
    t.string   "title"
    t.integer  "discount"
    t.string   "image_url"
    t.integer  "cost"
    t.integer  "price"
    t.date     "ends_at"
    t.text     "description"
    t.string   "subway"
    t.string   "address"
    t.string   "provider_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.integer  "city_id"
  end

  add_index "kupongid", ["kupongid_id"], :name => "index_kupongid_on_kupongid_id", :unique => true

  create_table "offers", :force => true do |t|
    t.integer  "provider_id"
    t.string   "provided_id"
    t.integer  "category_id"
    t.integer  "country_id"
    t.integer  "city_id"
    t.string   "title"
    t.integer  "discount"
    t.integer  "price"
    t.integer  "cost"
    t.string   "image"
    t.date     "ends_at"
    t.text     "description"
    t.string   "subway"
    t.string   "address"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "retail"
    t.integer  "retail_price"
    t.integer  "price_starts_at"
  end

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "auth_url"
    t.text     "auth_params"
    t.string   "logo_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
