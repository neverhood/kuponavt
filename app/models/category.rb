class Category < ActiveRecord::Base

  validates :name, :presence => true, :length => { :within => (3..50) }, :uniqueness => true

  has_many :offers, :dependent => :destroy
  has_many :nested_categories, :class_name => 'Category', :foreign_key => 'parent_category_id', :dependent => :destroy

  scope :parent_categories, where(:parent_category_id => nil).where('special is NULL or special is FALSE')
  scope :nested_categories, where(['parent_category_id IS NOT NULL'])

  scope :food_and_fun, find_by_parent_category_id(1)
  scope :beauty_and_health, find_by_parent_category_id(9)
  scope :learning, find_by_parent_category_id(13)
  scope :goods_and_services, find_by_parent_category_id(15)
  scope :rest, find_by_parent_category_id(23)

  after_destroy lambda { |category| category.nested_categories.each { |c| c.destroy } if category.parent? }

  def nest_category(category_name)
    Category.create :name => category_name, :parent_category_id => id
  end

  def city_offers(city_id)
    offers.joins(:cities).where(['cities_offers.city_id = ?', city_id])
  end

  def nested_categories_offers(city_id)
    Offer.joins(:cities).
      where(['cities_offers.city_id = ?', city_id]).
      where(category_id: nested_categories.map(&:id))
  end

  def parent?
    parent_category_id.nil?
  end

  def to_en
    case self.id
      when 1 then 'food-and-fun'
      when 9 then 'beauty-and-health'
      when 13 then 'learning'
      when 15 then 'goods-and-services'
      when 23 then 'rest'
    end
  end

end
