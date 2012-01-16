# encoding: UTF-8

require File.expand_path('../lib/mixins/kupongid_tools', __FILE__)
include KupongidTools

bot = KupongidTools.authenticate! Mechanize.new, login: 'khomich.vlad@gmail.com', password: 'mfaunbby'

cities = KupongidTools.cities # Cities mapping

cities.keys.each do |city|

  existing_offers = KupongidTools.existing_offers(city.id)
  processed_offers = []

  bot.get( cities[city] )

  # Pagination
  current_page = 0
  pagination = bot.page.parser.css('.pagination a')
  pages = (1..( pagination.slice(0, pagination.length - 2).last.text.to_i )).to_a

  pages.each do |page_index|
    page_url = bot.page.parser.css('.pagination a').find { |a| a.text.strip == page_index.to_s }

    if page_url
      puts "Going to page #{page_index}"
      begin
        bot.get page_url['href']
      rescue Exception
        bot.get page_url['href']
      end
      current_page = page_index
    else
      break unless page_index == 1 # 1 is current page
    end

    offer_patterns = bot.page.parser.css('noindex .deal').map { |pattern| KupongidTools::Pattern.new pattern }.
      select { |pattern| pattern.should_follow? }
    new_offers = offer_patterns.select { |pattern| not existing_offers.include?(pattern.offer_id) }
    processed_offers += offer_patterns.map(&:offer_id)

    new_offers.each do |offer_pattern|
      begin
        offer = Offer.new(offer_pattern.attributes.merge({city_id: city.id, country_id: city.country_id}))
        puts "Failed to save offer: #{offer_pattern.provider_url}" unless offer.save
      rescue Exception
        puts 'faced TIMEOUT, skipping offer: ' + offer_pattern.url
      end
    end
  end

  old_offers = existing_offers - processed_offers

  binding.pry if old_offers.any?

end