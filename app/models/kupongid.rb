class Kupongid < ActiveRecord::Base

  set_table_name :kupongid

  belongs_to :city
  belongs_to :country
  belongs_to :category

  scope :by_categories, lambda { |categories|
    joins(:category).
      where(['categories.name IN (:category_names)', :category_names => categories.join(',')])
  }

  def self.default_sort
    "category_id, kupongid.ends_at DESC"
  end

end
