class Country < ActiveRecord::Base

  has_many :cities, :dependent => :destroy
  has_many :offers, :through => :cities, :dependent => :destroy

end
