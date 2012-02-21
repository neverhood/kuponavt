class OffersController < ApplicationController

  SEARCH_QUERY_REGEXP = /(\+|-|&&|\|\||!|\(|\)|{|}|\[|\]|`|"|~|\?|:|\\)/

  layout Proc.new { |controller| controller.request.xhr?? false : 'application' }

  before_filter :validate_city, :only => [ :index, :search, :refresh ]
  before_filter :prepare_cookies, :only => [ :index, :show, :search, :neighbors ]
  before_filter :validate_offer, :only => [:show, :neighbors]
  before_filter :prepare_offers_scope, :only => [ :index, :show, :neighbors ]

  caches_action :index, :cache_path => Proc.new { |controller|
    p = controller.params
    categories = p['categories'] ? p['categories'].gsub(',','-') : ''
    sort = p['sort'] ? (p['sort']['attribute'] + '_' + p['sort']['direction']) : ''
    page = p['page'] || 1
    city = p['city']
    per_page = @kuponavt_cookies[:per_page] || 25
    time_period = p['time_period']
    "#{[categories, sort, time_period, page, per_page, city].join('_')}.index_fragment"
    # 2-3_category_id_desc_2_100_moskva.index_fragment
    # ^ category ids ^ sort ^ page ^ per_page ^ city
  }

  # before_filter :prepare_page_index, :only => [ :index, :search ]
  # before_filter :prepare_categories_array, :only => :index
  # before_filter :prepare_sort_attributes, :only => :index
  # before_filter :prepare_time_period, :only => :index
  before_filter :validate_favourites, :only => :favourites, :if => lambda { |controller| controller.request.xhr? }
  before_filter :validate_search, :only => :search

  def index
    # if request.xhr?
    #   @offers = @categories ? @city.offers.with_dependencies.
    #     where(category_id: @categories).
    #     order(@sort_by).
    #     page( @page ).per( @per_page )
    #   : []
    #   if @time_period && @categories
    #     @offers = @offers.by_time_period(@time_period)
    #   end

    #   if @time_period
    #     @offers_selected_count = @categories ? @city.offers.
    #       where(category_id: @categories).by_time_period(@time_period).count : @city.offers.categorized.count
    #   else
    #     @offers_selected_count = @categories ? @city.offers.
    #       where(category_id: @categories).count : @city.offers.where('offers.category_id is NOT NULL').count
    #   end
    # else
    #   @offers = Offer.where('id < 0').page( params[:page] ) # empty scope for pagination
    #   @offers_selected_count = 0
    # end

    # if request.xhr?
    #   @offers_selected_count = @offers.total_count
    #   # if @kuponavt_cookies[:time_period]
    #   #   @offers_selected_count = @kuponavt_cookies[:categories] ? @city.offers.
    #   #     where(category_id: @kuponavt_cookies[:categories]).by_time_period(@kuponavt_cookies[:time_period]).count : @city.offers.categorized.count
    #   # else
    #   #   @offers_selected_count = @categories ? @city.offers.
    #   #     where(category_id: @categories).count : @city.offers.where('offers.category_id is NOT NULL').count
    #   # end
    # else
    #   @offers_selected_count = 0
    # end

    @offers_selected_count = request.xhr?? @offers.total_count : 0
    @offers_total_count = @city.offers.where('offers.category_id is NOT NULL').count

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
      limit = request.xhr?? 3 : 50

      if @offers.except(:limit, :offset).where(id: @offer.id).count > 0
        neighbors = @offer.neighbors( @offers, limit )
      else
        neighbors = @offer.neighbors( @city.offers.
          where(category_id: @offer.category_id ).
          order("offers.created_at desc"), limit )
      end

      if neighbors.nil?
        neighbors = @offer.neighbors( City.find( @offer.city_id ).offers.
                                     where(category_id: @offer.category_id ).
                                     order('offers.created_at desc'), limit )
        @foreign = true if neighbors
      end

      format.html do
        @before, @after = neighbors[:before], neighbors[:after]
      end

      format.json do
        json = {}
        unless neighbors[:before].first.nil?
          json[:before] = neighbors[:before].map do |id|
            {id: id, html: render_to_string(partial: 'single_offer', locals: { offer: Offer.find(id) })}
          end
        end
        unless neighbors[:after].first.nil?
          json[:after] = neighbors[:after].map do |id|
            {id: id, html: render_to_string(partial: 'single_offer', locals: { offer: Offer.find(id) })}
          end
        end

        render json: json
      end
    end
  end

  def neighbors
    neighbors = @offer.neighbors( @offers, 50 )
    @before, @after = neighbors[:before], neighbors[:after]

    render json: { before: @before, after: @after }
  end

  def search
    @offers = @city.offers.search("*#{@search}*", per_page: 25, page: @page, load: true)
    render :json => { :offers => render_to_string( partial: 'offer', collection: @offers ), :total => @offers.total,
      :pagination => render_to_string( partial: 'remote_pagination' ) }
  end


  private

  def validate_city
    @city = City.where(:name => params[:city]).first
    cookies[:kuponavt_city] = { value: @city.id, expires: 14.days.from_now } if @city
    redirect_to root_path unless @city
  end

  def prepare_offers_scope
    if request.xhr? || action_name == 'show'
      unless @city
        redirect_to root_path unless City.where(id: (cookies[:kuponavt_city] ? cookies[:kuponavt_city] : @offer.city_id) ).count > 0
        @city = cookies[:kuponavt_city] ? City.find( cookies[:kuponavt_city] ) : City.find( @offer.city_id )
      end

      @offers = @kuponavt_cookies[:categories] ? @city.offers.with_dependencies.
        where(category_id: @kuponavt_cookies[:categories]).
        order(@kuponavt_cookies[:sort]).
        page( @kuponavt_cookies[:page] ).per( @kuponavt_cookies[:per_page] )
      : []
      @offers = @city.offers.order( "offers.category_id desc, offers.created_at desc" ) if @offers == [] && action_name == 'show'

      if @kuponavt_cookies[:time_period] && @kuponavt_cookies[:categories] # Looks like categories check is redundant here
        @offers = @offers.by_time_period(@kuponavt_cookies[:time_period])
      end
    else
      @offers = Offer.where('id < 0').page( params[:page] )
    end
  end

  def validate_favourites
    offers = params[:offers].split(',').keep_if { |offer_id| offer_id =~ /^\d+$/ }
    @offers = Offer.where(:id => offers)

    render(:json => { :count => 0 }) unless @offers.count >= 1
  end

  def validate_offer
    @offer = Offer.where(id: params[:id]).first
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

  def prepare_cookies
    @kuponavt_cookies ||= kuponavt_cookies
  end

end
