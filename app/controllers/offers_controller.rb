class OffersController < ApplicationController

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  before_filter :validate_city

  def index
    @offers = @city.offers.page( params[:page] || 1 )

    respond_to do |format|
      format.html
      format.js do
        render :json => { :offers => render_to_string(:partial => 'offers/offers'),
          :pagination => render_to_string(:partial => 'offers/pagination')
        }, :layout => false
      end
    end
  end

  def show
    @offer = Offer.find params[:id]
  end


  private

  def validate_city
    @city = City.where(:name => params[:city]).first
    redirect_to root_path unless @city
  end


end
