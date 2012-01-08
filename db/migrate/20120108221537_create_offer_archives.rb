class CreateOfferArchives < ActiveRecord::Migration
  def change
    create_table :offer_archive do |t|
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
      t.datetime 'archived_at'

      t.timestamps
    end
  end
end
