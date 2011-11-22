class OffersController < ApplicationController

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :if => proc { |controller| controller.request.xhr? }

  before_filter :validate_city
  before_filter :prepare_categories_array

  def index
    @offers = (@categories ? @city.offers.by_categories(@categories) : @city.offers).page( params[:page] )
    @offers_total_count = @city.offers.count
    @offers_selected_count = @categories ? @city.offers.by_categories(@categories).count : @city.offers.count

    respond_to do |format|
      format.html
      format.js do
        #render :json => { :offers => @offers.to_json,
        #  :pagination => render_to_string(:partial => 'offers/pagination'),
        #  :count => @offers_selected_count
        #}
        render :json => { :offers => render_to_string(:partial => 'offers/offers'),
          :pagination => render_to_string(:partial => 'offers/pagination'), :count => @offers_selected_count
        }, :layout => false
      end
    end
  end

  def show
    @offer = Offer.find params[:id]
  end


  private

  def prepare_categories_array
    @categories = params[:categories] && params[:categories].split(',')
  end

  def validate_city
    @city = City.where(:name => params[:city]).first
    redirect_to root_path unless @city
  end


end
