class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :refresh_cookies

  helper_method :russian_cities, :ukrainian_cities, :parse_cookies

  def russian_cities
    Country.find_by_name('russia').cities
  end

  def ukrainian_cities
    Country.find_by_name('ukraine').cities
  end

  def kuponavt_cookies
    if cookies[:kuponavt_params]
      kuponavt_params, kuponavt_cookies = cookies[:kuponavt_params].split('|'), {}

      kuponavt_cookies[:page] = kuponavt_params[3].to_i > 0 ? kuponavt_params[3].to_i : 1
      kuponavt_cookies[:per_page] = kuponavt_params[4].to_i % 25 == 0 ? kuponavt_params[4].to_i : 25
      kuponavt_cookies[:categories] = kuponavt_params[1] == 'all' ? Category.select(:id).map(&:id) : kuponavt_params[1].split(',').
          keep_if { |id| id =~ /\d+/ }

      time_period = [0,1,2].include?(kuponavt_params[2].to_i) ? kuponavt_params[2].to_i : 0
      sort = kuponavt_params[0].split

      if %(category_id created_at price discount ends_at).include?(sort.first) && %(asc desc).include?(sort.last)
        if sort.first == 'category_id'
          kuponavt_cookies[:sort] = "offers.category_id #{sort.last}, offers.created_at desc"
        else
          kuponavt_cookies[:sort] = "offers.#{sort.first} #{sort.last}"
        end
      else
        kuponavt_cookies[:sort] = Offer.default_sort
      end

      kuponavt_cookies[:time_period] = case time_period
                     when 1 then [Time.now.utc.to_date]
                     when 2 then [1.day.ago.utc.to_date, Time.now.utc.to_date]
                   end

      kuponavt_cookies

    else
      {}
    end
  end

  private

  def refresh_cookies
    return unless cookies['favourites']

    favourites = []
    cookies['favourites'].split(',').each do |favourited|
      favourites << favourited if Offer.where(id: favourited.gsub(/_.*/, '')).count > 0
    end
    cookies['favourites'] = favourites.join(',')
  end
end
