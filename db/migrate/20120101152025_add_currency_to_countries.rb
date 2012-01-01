class AddCurrencyToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :currency, :string
  end
end
