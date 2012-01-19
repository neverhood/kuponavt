class AddIndexesToOffers < ActiveRecord::Migration
  def change
    add_index :offers, :created_at
    add_index :offers, :price
    add_index :offers, :discount
    add_index :offers, :ends_at
  end
end
