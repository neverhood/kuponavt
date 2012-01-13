class AddFromKupongidToOfferArchive < ActiveRecord::Migration
  def change
    add_column :offer_archive, :from_kupongid, :boolean
  end
end
