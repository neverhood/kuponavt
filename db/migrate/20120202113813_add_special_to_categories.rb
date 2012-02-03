class AddSpecialToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :special, :boolean
  end
end
