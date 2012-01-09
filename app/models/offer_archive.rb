class OfferArchive < ActiveRecord::Base

  set_table_name :offer_archive

  validates :provided_id, :uniqueness => { :scope => :provider_id }, :presence => true
  validates :cost, :presence => true

end
