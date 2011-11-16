class Category < ActiveRecord::Base

  validates :name, :presence => true, :length => { :within => (3..50) }, :uniqueness => true

  has_many :offers, :class_name => 'Kupongid'

  scope :parent_categories, where(:parent_category_id => nil).all

  scope :food_and_fun, find_by_parent_category_id(1)
  scope :beauty_and_health, find_by_parent_category_id(2)
  scope :learning, find_by_parent_category_id(3)
  scope :goods_and_services, find_by_parent_category_id(4)
  scope :rest, find_by_parent_category_id(22)


  def nest_category(category_name)
    Category.create :name => category_name, :parent_category_id => id
  end

  def nested_categories
    self.to_en == 'rest' ? [self] : Category.where(:parent_category_id => id)
  end

  def parent?
    parent_category_id.nil?
  end

  def to_en
    case self.id
      when 1 then 'food-and-fun'
      when 2 then 'beauty-and-health'
      when 3 then 'learning'
      when 4 then 'goods-and-services'
      when 22 then 'rest'
    end
  end

end
