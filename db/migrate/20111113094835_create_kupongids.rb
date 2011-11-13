class CreateKupongids < ActiveRecord::Migration
  def self.up
    create_table :kupongid, :primary_key => false do |t|
    #  t.integer :site_id, :null => false
      t.integer :kupongid_id, :null => false
      t.string :provider
      t.string :country, :default => 'ukraine'
      t.string :city, :default => 'kyiv'
      t.string :url, :null => false
      t.string :title
      t.integer :discount
      t.string :image_url
      t.integer :cost
      t.integer :price
      t.date :ends_at
      t.text :description
      t.string :subway
      t.string :address
      t.string :provider_url

      t.timestamps
    end

    add_index :kupongid, :kupongid_id, :unique => true

  end

  def self.down
    drop_table :kupongid
  end
end
