class CreateCitiesOffers < ActiveRecord::Migration
  def change
    create_table :cities_offers do |t|
      t.integer :city_id
      t.integer :offer_id
    end

    add_index :cities_offers, :city_id
    add_index :cities_offers, :offer_id
  end
end
