class Offer < ActiveRecord::Base

  include Tire::Model::Search
  include Tire::Model::Callbacks

  #settings :number_of_shards => 1,
           #:number_of_replicas => 1,
           #:analysis => {
             #:filter => {
               #:russian_stemmer => {
                 #"type" => "stemmer",
                 #"name" => "light_russian"
               #}
             #},
             #:analyzer => {
               #:russian_analyzer => {
                 #"tokenizer" => "lowercase",
                 #"filter" => ["standard", "lowercase", "russian_stemmer"],
                 #"type" => "snowball",
                 #"language" => "russian"
               #}
             #}
           #} do
             #mapping do
               #indexes :title, :analyzer => :russian_analyzer, :boost => 2
               #indexes :description, :analyzer => :rusian_analyzer
               #indexes :subway, :analyzer => :russian_analyzer
               #indexes :address, :analyzer => :russian_analyzer
             #end
           #end

  mapping do
    indexes :title, :analyzer => 'snowball'
    indexes :description, :analyzer => 'snowball'
    indexes :subway, :analyzer => 'snowball'
    indexes :address, :analyzer => 'snowball'
  end

  attr_accessor :remote_image_url

  has_and_belongs_to_many :cities
  belongs_to :country
  belongs_to :provider
  belongs_to :category

  validates :provided_id, :uniqueness => { :scope => :provider_id }, :presence => true
  validates :cost, :presence => true

  mount_uploader :image, PictureUploader

  after_destroy :destroy_image_and_folder

  before_create lambda { |offer| offer.url.gsub! /\/$/, '' }

  scope :by_categories, lambda { |categories|
    where(category_id: categories.join(','))
    #joins(:category).
      #where(['categories.name IN (:category_names)', :category_names => categories.join(',')])
  }
  scope :categorized, where('`offers`.`category_id` IS NOT NULL').order('`offers`.`category_id` DESC')
  scope :newest_first, order('`offers`.`created_at` DESC')
  scope :with_dependencies, includes(:provider).includes(:country)

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


  #def price
    #return read_attribute(:price) if read_attribute(:price)

  #end

  def ends_at
    case read_attribute(:ends_at)
      when nil then 1.day.from_now.to_date
      else read_attribute(:ends_at)
    end
  end

  def finished?
    ends_at < Time.now.to_date
  end

  def is_about_to_finish?
    ends_at == 1.day.from_now.to_date
  end

  private

  def destroy_image_and_folder
    return unless image_url
    directory = "public/#{File.dirname(image_url)}"
    remove_image!
    FileUtils.rm_rf(directory) if directory
  end


end
