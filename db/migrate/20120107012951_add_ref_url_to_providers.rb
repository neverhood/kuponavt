class AddRefUrlToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :ref_url, :string
  end
end
