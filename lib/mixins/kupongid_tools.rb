# encoding: UTF-8
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
    Offer.where(city_id: city_id, from_kupongid: true).map(&:provided_id)
  end

  class Pattern

    BOT = Mechanize.new
    require 'open-uri'

    attr_accessor :source, :provider_id, :offer_id, :url

    def initialize(pattern)
      @provider_id = pattern.css('.negotiated a').first['href'].scan(/\d+/).first.to_i
      @offer_id = pattern.css('div').first['id'].gsub('deal', '')
      @url = pattern.css('.h2 a').first['href']
      @source = nil
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

    def attributes
      self.source = BOT.get(self.url).
        parser.css('#content')

      {
        provided_id: self.offer_id,
        title: title,
        discount: discount,
        cost: cost,
        price: price,
        ends_at: ends_at,
        image: image,
        description: description,
        subway: subway,
        address: address,
        url: provider_url
      }
    end

    def title
      source.css('h1').first.text
    end

    def discount
      source.css('.percent').first.text.to_i
    end

    def cost
      source.css('.discount .bold1[style]').text.to_i
    end

    def price
      binding.pry
      source.css('.discount .bold1').last.text.to_i
    end

    def ends_at
      (source.css('.countdown').first['data-time-left'].to_i/3600 + 2).hours.from_now.to_date
      #(Time.now + ( 7200 + source.css('.countdown').first['data-time-left'].to_i )).to_date
    end

    def image
      open( source.css('.image_cont img').first['src'] )
    end

    def description
      source.css('div[style]')[1].css('p')[1].to_html.encode('utf-8')
    end

    def subway
      sbway = source.css(".address").text.strip.gsub(/\s*-\s*показать/, '').split('|').first
      return nil if sbway && sbway.gsub(/[ ,-\\"'`]*/, '').empty?

      sbway.strip
    end

    def address
      source.css("div.deal .address").text.strip.gsub(/\s*-\s*показать/, '').split('|').map(&:strip).last
    end

    def provider_url
      begin
        out_page = BOT.get(source.css(".formbutton").last['href'])
        if out_page.uri.to_s =~ /kupongid/
          out_page.links.last.href.gsub /\?.*/, ''
        else
          out_page.uri.to_s.gsub /\?.*/, ''
        end
      rescue Exception => e
        nil
      end
    end

  end

end
