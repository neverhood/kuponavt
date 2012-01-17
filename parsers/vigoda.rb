# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

PROVIDER = Provider.where(name: 'vigoda').first

cities = {
  City.where(name: 'kiev').first => 'http://kiev.vigoda.ru/all',
  City.where(name: 'moskva').first => 'http://vigoda.ru/',
  City.where(name: 'sankt-peterburg').first => 'http://spb.vigoda.ru/all'
}

@bot = Mechanize.new
@log = Logger.new(File.expand_path('../logs/vigoda.log', __FILE__))
saved = 0

def parser(selector)
  @bot.page.parser.css(selector)
end

@log.debug("Starting vigoda parser: #{Time.now}")

cities.keys.each do |city|
  existing_offers = city.offers.where(:provider_id => PROVIDER.id).map(&:provided_id)
  @saved_offers = []

  @log.info("Going to #{city.name}: #{cities[city]}")
  @bot.get cities[city]

  offers = []
  @bot.page.links_with(:href => /offer/).map(&:href).uniq.each do |offer_url|
    offer_url.gsub! /%.*/, ''
    offers << { url: offer_url, provided_id: offer_url.gsub(/\D/, '') }
  end

  offers.each do |offer|

    if existing_offers.include?(offer[:provided_id]) || @saved_offers.include?(offer[:provided_id])
      @log.info("Skipping existing offer: #{offer[:provided_id]}")
      existing_offers.delete(offer[:provided_id])
      next
    end

    if Offer.where(provided_id: offer[:provided_id], provider_id: PROVIDER.id).any?
      existing_model = Offer.where(provided_id: offer[:provided_id], provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer[:url])
      @log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      next
    end

    offer[:provider_id] = PROVIDER.id
    offer[:country_id] = city.country_id
    offer[:city_id] = city.id

    @bot.get offer[:url]


    offer[:title] = parser('table.content div .pointer-hand').first.text.strip
    offer[:price] = parser('div.main-buy-label div.pointer-hand div').first || 0
    #next if params[:price].nil?
    offer[:price] = offer[:price].text.gsub(',','').to_i if offer[:price]
    if offer[:price] == 0 # STARTS_AT
      offer[:price] = parser('div.main-buy-label div.pointer-hand div')[1].text.gsub(',','').to_i
    end
    offer[:cost] = parser('td.price-discount-profit td div').first.text.strip.gsub(',','').to_i
    offer[:discount] = parser('td.price-discount-profit td div')[1].text.strip.to_i
    begin
      offer[:image] = open(parser('img.pointer-hand').first[:src])
    rescue Exception => e
      offer[:image] = nil
    end

    offer_desc = parser('div.conditions')
    offer_desc.css('a').each do |a|
      a['target'] = '_blank'
      a['rel'] = 'nofollow'
    end
    offer[:description] = offer_desc.to_html.strip
    offer[:address] = $1 if parser('.main-benefits-right').text =~ /Основной адрес:\s*(.*)\s*, Тел/

    model = Offer.new(offer)
    if model.valid?
      city.offers << model
      @log.info("Saving offer: #{model.provided_id}")
      @saved_offers << model.provided_id
      saved += 1
    else
      @log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
    end
    @bot = Mechanize.new

  end

  existing_offers.each do |expired_offer|
    @log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end

  @log.info("Finished parsing #{city.name}. Total of #{@saved_offers.count} new offers saved, #{existing_offers.count} are expired and were deleted")

end

@log.info "Finished parsing vigoda. Total of #{saved} new offers were added"
