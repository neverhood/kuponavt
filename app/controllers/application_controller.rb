class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :refresh_cookies

  helper_method :russian_cities, :ukrainian_cities

  def russian_cities
    Country.find_by_name('russia').cities
  end

  def ukrainian_cities
    Country.find_by_name('ukraine').cities
  end

  private

  def refresh_cookies
    return unless cookies['favourites']

    favourites = []
    cookies['favourites'].split(',').each do |favourited|
      favourites << favourited if Offer.where(id: favourited.gsub(/_.*/, '')).count > 0
    end
    cookies['favourites'] = favourites.join(',')
  end
end
