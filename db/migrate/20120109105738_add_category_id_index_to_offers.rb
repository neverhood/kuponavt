class AddCategoryIdIndexToOffers < ActiveRecord::Migration

  def self.up
    add_index :offers, :category_id
  end

  def self.down
    remove_index :offers, :category_id
  end

end
