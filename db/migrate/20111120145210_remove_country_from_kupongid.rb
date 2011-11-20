class RemoveCountryFromKupongid < ActiveRecord::Migration
  def up
    remove_column(:kupongid, :city)
    remove_column(:kupongid, :country)
  end

  def down
    add_column(:kupongid, :city, :string)
    add_column(:kupongid, :country, :string)
  end
end
