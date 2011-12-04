class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.integer :provider_id
      t.string :provided_id
      t.integer :category_id
      t.integer :country_id
      t.integer :city_id
      t.string :title
      t.integer :discount
      t.integer :price
      t.integer :cost
      t.string :image_url
      t.date :ends_at
      t.text :description
      t.string :subway
      t.string :address
      t.string :url

      t.timestamps
    end

#    add_index :offers, [:provider_id, :provided_id], :unique => true
  end

  def self.down
    drop_table :offers
  end

end
