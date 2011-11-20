class City < ActiveRecord::Base

  belongs_to :country
  has_many :offers, :class_name => 'Kupongid'

  validates :name, :uniqueness => { :scope => :country_id }
  validates :country, :presence => true

  def self.default
    City.where(:name => 'kiev').first
  end

  def to_param
    name
  end

end
