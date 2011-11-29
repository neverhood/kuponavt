class City < ActiveRecord::Base

  belongs_to :country
  has_many :offers, :class_name => 'Kupongid' do

    def by_categories(categories)
      joins(:category).where(['categories.id IN (:category_ids)', { :category_ids => categories }])
    end

  end

  validates :name, :uniqueness => { :scope => :country_id }
  validates :country, :presence => true

  def self.default
    City.where(:name => 'kiev').first
  end

  def to_param
    name
  end

end
