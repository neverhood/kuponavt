class AddRussianNameToCities < ActiveRecord::Migration
  def change
    add_column :cities, :russian_name, :string
  end
end
