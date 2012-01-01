class Provider < ActiveRecord::Base

  serialize :auth_params, Hash
  has_many :offers

  validates :name, :uniqueness => true

end
