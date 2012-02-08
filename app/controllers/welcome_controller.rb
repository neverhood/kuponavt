class WelcomeController < ApplicationController

  def index
    if cookies[:kuponavt_city]
      @city = City.where(id: cookies[:kuponavt_city]).count > 0 ? City.find(cookies[:kuponavt_city]) : City.default
      redirect_to offers_path(@city)
    else
      @city = Struct.new(:name).
        new(:choose_city)
    end
  end

end
