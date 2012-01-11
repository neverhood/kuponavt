class AddRetailToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :retail, :boolean
    add_column :offers, :retail_price, :integer
    add_column :offers, :price_starts_at, :integer
  end
end
