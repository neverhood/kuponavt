class CitiesOffers < ActiveRecord::Base
  validates :offer_id, :uniqueness => { :scope => :city_id }
end
