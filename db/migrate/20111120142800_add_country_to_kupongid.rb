class AddCountryToKupongid < ActiveRecord::Migration
  def change
    add_column :kupongid, :country_id, :integer
    add_column :kupongid, :city_id, :integer
  end
end
