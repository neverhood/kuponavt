class CrawlingException < ActiveRecord::Base

  belongs_to :provider

  serialize :offer_attributes, Hash

end
