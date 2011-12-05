class Offer < ActiveRecord::Base

  attr_accessor :remote_image_url

  belongs_to :city
  belongs_to :country
  belongs_to :provider
  belongs_to :category

  mount_uploader :image, PictureUploader

  scope :by_categories, lambda { |categories|
    joins(:category).
      where(['categories.name IN (:category_names)', :category_names => categories.join(',')])
  }

  def self.default_sort
    "category_id, offers.ends_at DESC"
  end


  def price
    return read_attribute(:price) if read_attribute(:price)

    retail ? retail_price : price_starts_at
  end


end
