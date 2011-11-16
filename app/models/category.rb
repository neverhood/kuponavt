class Category < ActiveRecord::Base

  validates :name, :presence => true, :length => { :within => (3..50) }

  def nested_categories
    Category.where(:parent_category_id => id)
  end

  def parent?
    parent_category_id.nil?
  end

end
