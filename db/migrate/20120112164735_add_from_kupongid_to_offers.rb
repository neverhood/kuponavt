class AddFromKupongidToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :from_kupongid, :boolean
  end
end
