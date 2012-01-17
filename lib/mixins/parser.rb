module Parser

  def self.set_environment
    $rails_root = (File.expand_path('../../../', __FILE__))
    $LOAD_PATH << $rails_root
    $rails_env = ENV['RAILS_ENV'] || 'development'
  end

  def self.set_carrierwave
    CarrierWave.configure do |config|
      config.root = "#{$rails_root}/public"
    end
  end

  def self.set_activerecord
    db_config = YAML::load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config[$rails_env])
  end

  def self.set_open_uri_limit( limit )
    OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
    OpenURI::Buffer.const_set 'StringMax', limit
  end

  def self.included(base)
    self.set_environment

    require 'active_record'
    require 'pry'
    require 'mechanize'
    require 'open-uri'
    require 'logger'
    require 'tire'
    require 'carrierwave'
    require 'carrierwave/orm/activerecord'
    require 'app/uploaders/picture_uploader'
    require 'app/models/provider'
    require 'app/models/offer'
    require 'app/models/city'
    require 'app/models/cities_offers'
    require 'app/models/country'

    self.set_open_uri_limit( 0 )
    self.set_carrierwave
    self.set_activerecord
  end



end
