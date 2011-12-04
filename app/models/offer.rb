class Offer < ActiveRecord::Base

  attr_accessor :remote_image_url

  belongs_to :city
  belongs_to :country
  belongs_to :provider

  mount_uploader :image, PictureUploader

end
