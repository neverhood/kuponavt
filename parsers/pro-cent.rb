require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

@url = 'http://pro-cent.ru'
@bot = Mechanize.new
@provider = PROVIDER = Provider.where(:name => 'pro-cent').first
@existing_offers = Offer.where(provider_id: @provider.id).map(&:provided_id)
@log = Logger.new(File.expand_path('../logs/pro-cent.log', __FILE__))

city = City.find_by_name('moskva')
offer_urls = []
offers = []
saved_offers = []
saved = 0

@log.info("Starting pro-cent parser: #{Time.now} ... ")

def prepare_index(uri)
  uri.split('-').map { |piece| piece[0] }.join
end

@bot.get @url

@bot.page.parser.css('.actionBlock .actionWrapper .actionImgBlock .actionImgCont a').each do |a|
  offers << { url: @url + '/' + a['href'], provided_id: prepare_index( a['href'].gsub(/.*\//, '') ) }
end

@bot.page.parser.css('.paginate a').each do |page|
  @bot.get @url + page['href']

  @bot.page.parser.css('.actionBlock .actionWrapper .actionImgBlock .actionImgCont a').each do |a|
    offers << { url: @url + '/' + a['href'], provided_id: prepare_index( a['href'].gsub(/.*\//, '') ) }
  end
end

offers.each do |offer|

  if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
    @log.info("Skipping existing offer: #{offer[:provided_id]}")
    @existing_offers.delete(offer[:provided_id])
    offer = nil
    next
  end

  @bot.get offer[:url] rescue next # Fucked up site
  pattern = @bot.page.parser.css('.content')
  info = @bot.page.parser.css('.payinfo td')

  offer[:city_id] = city.id
  offer[:country_id] = city.country_id
  offer[:provider_id] = @provider.id
  offer[:title] = pattern.css('h1.title').text
  offer[:image] = open(Mechanize.new.get( @url + '/' + pattern.css('.fullActionImage img').first['src'] ).uri) # fucked up urls
  offer[:price] = pattern.css('table.button').last.css('.c').text.gsub(/\D/, '').to_i
  offer[:discount] = info[1].text.gsub(/\D/, '').to_i
  begin
    offer[:cost] = info[3].text.gsub(/\D/, '').to_i
  rescue
    offer[:cost] = 0
  end
  offer[:subway] = @bot.page.parser.css('.station').first.text rescue nil
  offer[:ends_at] = pattern.css('.tillBlock .timeblock .value').first.text.to_i.days.from_now rescue nil
  offer[:description] = pattern.css('.section .visible').text.gsub("\n", "<br />")
  offer[:address] = @bot.page.parser.css('.addressBlock .data .value').first.text
  offer[:address] = nil if offer[:address].blank?

  model = Offer.new( offer )

  if model.valid?
    city_clone = city.clone # city includes offers and raises as fuck ( memory )
    city_clone.offers << model
    @log.info("Saving offer: #{model.provided_id}")
    saved_offers << model.provided_id
    saved += 1
    city_clone = nil # Not sure if it's needed
  else
    @log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
  end
end

@existing_offers.each do |expired_offer|
  @log.info("Removing expired offer #{expired_offer}")
  Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
end


@log.info "Finished parsing pro-cent. Total of #{saved} new offers were added"
