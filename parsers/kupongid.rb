# encoding: UTF-8

require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

require File.expand_path('../../lib/mixins/kupongid_tools', __FILE__)
include KupongidTools

@bot = Mechanize.new #KupongidTools.authenticate! Mechanize.new, login: 'khomich.vlad@gmail.com', password: 'mfaunbby'
@log = Logger.new("#{$rails_root}/parsers/logs/kupongid.log")

@bot.get('http://www.kupongid.ru')
@log.debug("Starting kupongid parser .. #{Time.now}")

cities = KupongidTools.cities # Cities mapping

cities.keys.each do |city|

  @log.info("Processing city #{city.name}")

  existing_offers = KupongidTools.existing_offers(city)
  saved_offers = []

  @bot.get( cities[city] )

  # Pagination
  current_page = 0
  @pagination = @bot.page.parser.css('.pagination a')
  pages = (1..( @pagination.slice(0, @pagination.length - 2).last.text.to_i )).to_a

  pages.each do |page_index|
    page_url = @pagination.find { |a| a.text.strip == page_index.to_s }

    if page_url
      @log.info "Going to page #{page_index}"
      begin
        @bot.get page_url['href']
        @pagination = @bot.page.parser.css('.pagination a')
      rescue Exception
        @bot.get page_url['href']
        @pagination = @bot.page.parser.css('.pagination a')
      end
      current_page = page_index
    else
      break unless page_index == 1 # 1 is current page
    end
    @bot = Mechanize.new

    offer_patterns = @bot.page.parser.css('noindex .deal').map { |pattern| KupongidTools::Pattern.new pattern }.
      select { |pattern| pattern.should_follow? }

    offer_patterns.each do |offer_pattern|
      if saved_offers.include?(offer_pattern.provided_id) || existing_offers.include?(offer_pattern.provided_id)
        @log.info "Ignoring existing offer #{offer_pattern.provided_id}"
        existing_offers.delete(offer_pattern.provided_id)
      end

      if Offer.where(provided_id: offer_pattern.provided_id, from_kupongid: true).any?
        @log.info "Adding existing offer #{offer_pattern.provided_id} to #{city.name}"
        existing_model = Offer.where(provided_id: offer_pattern.provided_id, from_kupongid: true).first
        existing_model.cities << city
        existing_model = nil
      end

      begin
        model = Offer.new(offer_pattern.attributes.merge({country_id: city.country_id}))
        if model.valid?
          @log.info "Saving offer #{model.provided_id}"
          city_clone = city.clone
          city_clone.offers << model
          city_clone = nil
        else
          puts "Failed to save offer: #{offer_pattern.provider_url}" unless offer.save
        end

        saved_offers << model.provided_id
      end
    end

    #new_offers = offer_patterns.select { |pattern| not existing_offers.include?(pattern.offer_id) }
    #processed_offers += offer_patterns.map(&:offer_id)

    #new_offers.each do |offer_pattern|
      #begin
        #offer = Offer.new(offer_pattern.attributes.merge({country_id: city.country_id}))
        #puts "Failed to save offer: #{offer_pattern.provider_url}" unless offer.save
      #rescue Exception
        #puts 'faced TIMEOUT, skipping offer: ' + offer_pattern.url
      #end
    #end
  @log.info "Finished processing #{city.name}"

  end

  binding.pry if existing_offers.any?

end
