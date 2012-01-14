class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :russian_cities, :ukrainian_cities

  def russian_cities
    Country.find_by_name('russia').cities
  end

  def ukrainian_cities
    Country.find_by_name('ukraine').cities
  end
end
