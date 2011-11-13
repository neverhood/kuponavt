class OffersController < ApplicationController

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  def index
    @offers = Kupongid.page( params[:page] || 1 )

    respond_to do |format|
      format.html
      format.js do
        render :json => { :offers => render_to_string(:partial => 'offers/offers'),
          :pagination => render_to_string(:partial => 'offers/pagination')
        }
      end
    end
  end

  def show
    @offer = Offer.find params[:id]
  end


end
