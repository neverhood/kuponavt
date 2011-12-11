class Offer < ActiveRecord::Base

  attr_accessor :remote_image_url

  belongs_to :city
  belongs_to :country
  belongs_to :provider
  belongs_to :category

  mount_uploader :image, PictureUploader

  after_destroy :destroy_image_and_folder

  scope :by_categories, lambda { |categories|
    joins(:category).
      where(['categories.name IN (:category_names)', :category_names => categories.join(',')])
  }

  scope :by_time_period, lambda { |time_period|
    if time_period.count == 1
      where(['offers.created_at >= ?', time_period.first])
    else
      where(['offers.created_at >= ? AND offers.created_at < ?', time_period.first, time_period.last])
    end
  }

  def self.default_sort
    "category_id, offers.ends_at DESC"
  end


  def price
    return read_attribute(:price) if read_attribute(:price)

    retail ? retail_price : price_starts_at
  end

  private

  def destroy_image_and_folder
    directory = "public/#{File.dirname(image_url)}"
    remove_image!
    FileUtils.rm_rf(directory)
  end


end
