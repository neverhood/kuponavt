class OfferArchive < ActiveRecord::Base

  validates :provided_id, :uniqueness => { :scope => :provider_id }, :presence => true
  validates :cost, :presence => true

end
