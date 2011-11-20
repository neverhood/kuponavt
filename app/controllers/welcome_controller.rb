class WelcomeController < ApplicationController

  def index
    redirect_to offers_path(:city => City.default)
  end
end
