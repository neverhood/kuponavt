# encoding: UTF-8

require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

require File.expand_path('../../lib/mixins/kupongid_tools', __FILE__)
include KupongidTools

require 'tor-privoxy'
#@bot = Mechanize.new #KupongidTools.authenticate! Mechanize.new, login: 'khomich.vlad@gmail.com', password: 'mfaunbby'
@proxy = TorPrivoxy::Switcher.new '127.0.0.1', '', {8118 => 9050}
@bot = Mechanize.new
@bot.set_proxy(@proxy.host, @proxy.port)

puts @bot.get('http://ifconfig.me/ip').body

@log = Logger.new("#{$rails_root}/parsers/logs/kupongid.log")
@url = 'http://www.kupongid.ru'

@bot.get(@url)
@log.debug("Starting kupongid parser .. #{Time.now}")

cities = KupongidTools.cities # Cities mapping

cities.keys.each do |city|

  @log.info("Processing city #{city.name}")

  existing_offers = KupongidTools.existing_offers(city)
  saved_offers = []

  @bot.get( @url + '/' + cities[city] )

  # Pagination
  current_page = 0
  @pagination = @bot.page.parser.css('.pagination a')
  pages = (1..( @pagination.slice(0, @pagination.length - 2).last.text.to_i )).to_a

  pages.each do |page_index|
    page_url = @pagination.find { |a| a.text.strip == page_index.to_s }

    if page_url
      @log.info "Going to page #{page_index}"
      begin
        @bot.get(@url + page_url['href'])
        @pagination = @bot.page.parser.css('.pagination a')
      rescue Exception
        @bot.get(@url + page_url['href'])
        @pagination = @bot.page.parser.css('.pagination a')
      end
      current_page = page_index
    else
      break unless page_index == 1 # 1 is current page
    end

    offer_patterns = @bot.page.parser.css('noindex .deal').map { |pattern| KupongidTools::Pattern.new pattern }.
      select { |pattern| pattern.should_follow? }

    @bot = Mechanize.new
    @bot.set_proxy(@proxy.host, @proxy.port)

    offer_patterns.each do |offer_pattern|
      if saved_offers.include?(offer_pattern.offer_id) || existing_offers.include?(offer_pattern.offer_id)
        @log.info "Ignoring existing offer #{offer_pattern.offer_id}"
        existing_offers.delete(offer_pattern.offer_id)
        next
      end

      if Offer.where(provided_id: offer_pattern.offer_id, from_kupongid: true).any?
        @log.info "Adding existing offer #{offer_pattern.offer_id} to #{city.name}"
        existing_model = Offer.where(provided_id: offer_pattern.offer_id, from_kupongid: true).first
        existing_model.cities << city
        existing_model = nil
        next
      end

      begin
        model = Offer.new(offer_pattern.attributes.merge({country_id: city.country_id, city_id: city.id}))
        model = Offer.new if model.url.nil?
        if model.valid?
          @log.info "Saving offer #{model.provided_id}"
          city_clone = city.clone
          city_clone.offers << model
          city_clone = nil
        else
          puts "Failed to save offer: #{offer_pattern.url}"
        end

        saved_offers << model.provided_id
      end
    end
    offer_patterns = nil

  end

  saved_offers = nil
  @log.info "Finished processing #{city.name}"
  if existing_offers.any?
    Offer.where(from_kupongid: true, provided_id: existing_offers).each { |o|
        @log.info("Destroying expired offer #{o.provided_id}")
	o.destroy 
    }
  end


end
