class AddUrlToCitiesOffers < ActiveRecord::Migration
  def change
    add_column :cities_offers, :url, :string
  end
end
