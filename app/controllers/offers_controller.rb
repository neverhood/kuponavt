class OffersController < ApplicationController

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :if => proc { |controller| controller.request.xhr? }

  before_filter :validate_city
  before_filter :prepare_categories_array
  before_filter :prepare_sort_attributes
  before_filter :prepare_page_index

  def index
    @offers = if request.xhr?
                @categories ? @city.offers.by_categories(@categories).order(@sort_by).page( @page ) : []
              else
                @city.offers.page(@page)
              end

    @offers_total_count = @city.offers.count
    @offers_selected_count = @categories ? @city.offers.by_categories(@categories).count : @city.offers.count

    respond_to do |format|
      format.html
      format.js do
        # if params[:page] && params[:page].to_i > 1
        #   render :json => { :offers => @offers.to_json, :pagination => render_to_string(:partial => 'offers/pagination'), :count => @offers_selected_count }
        # else
        #   render :json => { :offers => @offers.to_json }
        # end
        if @page > 1
          render :json => { :offers => render_to_string(:partial => 'offers/offers'),
            :pagination => render_to_string(:partial => 'offers/pagination'), :count => @offers_selected_count
          }, :layout => false
        else
          render :json => { :offers => render_to_string(:partial => 'offers/offers') }
        end
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

  def prepare_sort_attributes
    return Kupongid.default_sort if params[:sort].nil?

    @sort_direction, @sort_attribute = params[:sort][:direction], params[:sort][:attribute]
    @sort_by = (@sort_attribute && @sort_direction) ? "kupongid.#{@sort_attribute} #{@sort_direction}" : Kupongid.default_sort
  end

  def validate_city
    @city = City.where(:name => params[:city]).first
    redirect_to root_path unless @city
  end

  def prepare_page_index
    @page = params[:page] ? params[:page].to_i : 1
  end

end
