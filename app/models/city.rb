class City < ActiveRecord::Base

  belongs_to :country

  validates :name, :uniqueness => true, :scope => :country_id
  validates :country

end
