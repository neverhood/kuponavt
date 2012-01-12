module KupongidTools

  # 1 = biglion, 10 = vigoda
  AVAILABLE_PROVIDERS = [ 1, 10 ]

  def self.authenticate! bot, login_params
    bot.get('http://www.kupongid.ru/')

    bot.page.form_with(id: 'login_form') { |form|
      form.login = login_params[:login]
      form.password = login_params[:password]
    }.submit
    bot
  end

  def self.cities
    Hash[[
      [ City.find_by_name('moskva'), 'moskva' ],
      [ City.find_by_name('kiev'), 'kiev' ]
    ]]
  end

  def self.existing_offers(city_id)
    ::Offer.where(city_id: city_id, from_kupongid: true).map(&:provided_id)
  end

  class Pattern

    attr_accessor :source, :provider_id, :offer_id, :url

    def initialize(pattern)
      @source = pattern
      @provider_id = pattern.css('.negotiated a').first['href'].scan(/\d+/).first.to_i
      @offer_id = pattern.css('div').first['id'].gsub('deal', '')
      @url = pattern.css('.h2 a').first['href']
    end

    def should_follow?
      #not KupongidTools::AVAILABLE_PROVIDERS.include?(offer_id)
      if KupongidTools::AVAILABLE_PROVIDERS.include?(offer_id)
        puts 'EXISTING PROVIDER'
        false
      else
        puts 'NOT EXISTING PROVIDER'
        true
      end
    end

  end

  class PagePattern
  end

end
