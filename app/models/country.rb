class Country < ActiveRecord::Base

  validates :name, :uniqueness => true

  has_many :cities, :dependent => :destroy
  has_many :offers, :through => :cities, :dependent => :destroy

end
