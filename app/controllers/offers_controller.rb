class OffersController < ApplicationController

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  caches_action :index, :cache_path => Proc.new { |controller| "#{controller.params}.#{request.format.symbol.to_s}" }
  caches_action :show, :cache_path => Proc.new { |controller| "offers/show/#{controller.params[:id]}.#{request.format.symbol.to_s}" }

  before_filter :validate_city, :only => :index
  before_filter :prepare_categories_array, :only => :index
  before_filter :prepare_sort_attributes, :only => :index
  before_filter :prepare_page_index, :only => :index

  before_filter :validate_offer, :only => :show

  before_filter :validate_favourites, :only => :favourites, :if => lambda { |controller| controller.request.xhr? }

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

  def favourites
    respond_to do |format|
      format.html
      format.js do
        render :json => { :offers => render_to_string(:partial => 'offers/offers'), :count => @offers.count }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => { description: @offer.description, address: @offer.address } }
    end
  end


  private

  def prepare_categories_array
    @categories = params[:categories] && params[:categories].split(',')
  end

  def prepare_sort_attributes
    return Offer.default_sort if params[:sort].nil?

    @sort_direction, @sort_attribute = params[:sort][:direction], params[:sort][:attribute]

    if @sort_attribute && @sort_direction
      if @sort_attribute == 'category_id'
        @sort_by = "offers.category_id #{@sort_direction}, offers.created_at desc"
      else
        @sort_by = "offers.#{@sort_attribute} #{@sort_direction}"
      end
    else
      @sort_by = Offer.default_sort
    end
  end

  def validate_city
    @city = City.where(:name => params[:city]).first
    redirect_to root_path unless @city
  end

  def prepare_page_index
    @page = params[:page] ? params[:page].to_i : 1
  end

  def validate_favourites
    offers = params[:offers].split(',').keep_if { |offer_id| offer_id =~ /^\d+$/ }
    @offers = Offer.where(['`offers`.`id` IN (?)', offers])

    render(:json => { :count => 0 }) unless @offers.count >= 1
  end

  def validate_offer
    @offer = Offer.find params[:id]
    if @offer.nil?
      request.xhr?? render(nothing: true) : redirect_to(root_path)
    end
  end

end
