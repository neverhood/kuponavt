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

ActiveRecord::Schema.define(:version => 20120108221537) do

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
    t.string "currency"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "crawling_exceptions", :force => true do |t|
    t.text     "stacktrace"
    t.integer  "provider_id"
    t.string   "error_text"
    t.text     "offer_attributes"
    t.string   "offer_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "offer_archive", :force => true do |t|
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
    t.datetime "archived_at"
  end

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
    t.string   "ref_url"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
