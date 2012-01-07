class Provider < ActiveRecord::Base

  serialize :auth_params, Hash
  has_many :offers
  has_many :crawling_exceptions # Hopefully not

  validates :name, :uniqueness => true

end
