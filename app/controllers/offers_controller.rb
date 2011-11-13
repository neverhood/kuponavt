class OffersController < ApplicationController

  def index
    @offers = Kupongid.page( params[:page] || 1 )
  end

  def show
    @offer = Offer.find params[:id]
  end


end
