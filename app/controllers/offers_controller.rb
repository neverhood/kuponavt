class OffersController < ApplicationController

  SEARCH_QUERY_REGEXP = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\)/

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  #caches_action :show, :cache_path => Proc.new { |controller| "offers/show/#{controller.params[:id]}.#{request.format.symbol.to_s}" }

  before_filter :validate_city, :only => [ :index, :search, :refresh ]

  caches_action :index, :cache_path => Proc.new { |controller| "#{controller.params}.#{@city.name}_index_fragment" }

  before_filter :prepare_categories_array, :only => :index
  before_filter :prepare_sort_attributes, :only => :index
  before_filter :prepare_time_period, :only => :index
  before_filter :prepare_page_index, :only => [ :index, :search ]
  before_filter :validate_offer, :only => :show
  before_filter :validate_favourites, :only => :favourites, :if => lambda { |controller| controller.request.xhr? }
  before_filter :validate_search, :only => :search

  def index
    if request.xhr?
      @offers = @categories ? @city.offers.with_dependencies.where(category_id: @categories).order(@sort_by).page( @page ) : []
      if @time_period && @categories
        @offers = @offers.by_time_period(@time_period)
      end
    else
      @offers = @city.offers.categorized.page(@page)
    end

    @offers_total_count = @city.offers.where('"offers".category_id is NOT NULL').count

    if @time_period
      @offers_selected_count = @categories ? @city.offers.where(category_id: @categories).by_time_period(@time_period).count : @city.offers.categorized.count
    else
      @offers_selected_count = @categories ? @city.offers.where(category_id: @categories).count : @city.offers.where('"offers".category_id is NOT NULL').count
    end

    respond_to do |format|
      format.html
      format.js do
        render :json => { :offers => render_to_string(partial: 'offer', collection: @offers),
          :pagination => render_to_string(:partial => 'pagination'), :count => @offers_selected_count
        }, :layout => false
      end
    end
  end

  def favourites
    respond_to do |format|
      format.html
      format.js do
        render :json => { :offers => render_to_string(:partial => 'offer', :collection => @offers), :count => @offers.count }
      end
    end
  end

  def out
    offer = cookies[:favourites] && cookies[:favourites].split(',').find { |offer| offer =~ /#{params[:id]}/ }
    if offer # favourited cookie
      @city = City.where(name: offer.gsub(/.*_/, '')).first
    else
      @city = City.where(name: params['city']).first
    end
    @offer = Offer.find(params[:id])
    if @offer && @city
      url = CitiesOffers.where(city_id: @city.id, offer_id: @offer.id).first.url || @offer.url
      redirect_to @offer.provider.ref_url ? (url + @offer.provider.ref_url) : url
    else
      render :nothing => true
    end
  end

  def refresh
    if request.xhr? && @city
      render :json => { filter: render_to_string(partial: 'filter') }
    else
      render :nothing => true
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => { description: @offer.description, address: @offer.address } }
    end
  end

  def search
    @offers = @city.offers.search("*#{@search}*", per_page: 25, page: @page, load: true)
    render :json => { :offers => render_to_string( partial: 'offer', collection: @offers ), :total => @offers.total,
      :pagination => render_to_string( partial: 'remote_pagination' ) }
  end


  private

  def prepare_categories_array
    if params[:categories] == 'all'
      @categories = Category.all.map(&:id)
    else
      @categories = params[:categories] && params[:categories].split(',')
    end
  end

  def prepare_sort_attributes
    return Offer.default_sort if params[:sort].nil?

    @sort_direction, @sort_attribute = params[:sort][:direction], params[:sort][:attribute]

    if @sort_attribute && @sort_direction
      if @sort_attribute == 'category_id'
        @sort_by = "offers.category_id #{@sort_direction}, offers.created_at desc"
      #elsif @sort_attribute == 'price'
        #@sort_by = "case when `offers`.`price` IS NULL then `offers`.`price_starts_at` else `offers`.`price` end #{@sort_direction}"
      else
        @sort_by = "offers.#{@sort_attribute} #{@sort_direction}"
      end
    else
      @sort_by = Offer.default_sort
    end
  end

  def prepare_time_period
    time_period = params[:time_period] && params[:time_period].to_i

    @time_period = case time_period
                     when 1 then [Time.now.utc.to_date]
                     when 2 then [1.day.ago.utc.to_date, Time.now.utc.to_date]
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

  def validate_search
    if params[:search] && params[:search].strip.length > 0
      @search = params[:search].gsub SEARCH_QUERY_REGEXP, "\\\\\\1"
    else
      render :nothing => true
    end
  end

end
