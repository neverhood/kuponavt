class RemoveRetailFromOffers < ActiveRecord::Migration
  def up
    remove_column :offers, :retail
    remove_column :offers, :price_starts_at
    remove_column :offers, :retail_price
    remove_column :offers, :updated_at
  end

  def down
    add_column :offers, :retail, :boolean
    add_column :offers, :price_starts_at, :integer
    add_column :offers, :retail_price, :integer
    add_column :offers, :updated_at, :datetime
  end
end
