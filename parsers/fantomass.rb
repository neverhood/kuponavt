require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

@url = 'http://fun2mass.ru'
@bot = Mechanize.new
@provider = PROVIDER = Provider.where(:name => 'fun2mass').first
@existing_offers = Offer.where(provider_id: @provider.id).map(&:provided_id)
@log = Logger.new(File.expand_path('../logs/fun2mass.log', __FILE__))
categories = ["http://fun2mass.ru/category/beauty", "http://fun2mass.ru/category/restaurants",
              "http://fun2mass.ru/category/entertainment", "http://fun2mass.ru/category/sport", "http://fun2mass.ru/category/study",
              "http://fun2mass.ru/category/health", "http://fun2mass.ru/category/auto", "http://fun2mass.ru/category/sell",
              "http://fun2mass.ru/category/tourism", "http://fun2mass.ru/category/other"
]

city = City.find_by_name('moskva')
offer_urls = []
offers = []
saved_offers = []
saved = 0

@log.info("Starting fun2mass parser: #{Time.now} ... ")

categories.each do |category|
  @bot.get(category)
  @bot.page.parser.css('#sh-list li a.sh-info').map { |a| offers << { provided_id: a['href'].gsub(/.*\//, ''), url: (@url + a['href']) } }
end

offers.each do |offer|

  if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
    @log.info("Skipping existing offer: #{offer[:provided_id]}")
    @existing_offers.delete(offer[:provided_id])
    offer = nil
    next
  end

  @bot.get offer[:url]

  pattern = @bot.page.parser.css('.share-single')
  info = pattern.css('.s1-info li')
  timer = pattern.css('.s1-time srcript')
  contacts = pattern.css('.content-block dl .metro')
  subways, addresses = [], []

  contacts.each do |subway|
    subways << subway.text
    addresses << subway.next.next.text
  end

  offer[:provider_id] = @provider.id
  offer[:title] = pattern.css('.content-block h1').first.text
  offer[:price] = pattern.css('.s1-price .s1-value').text.gsub(/\D/, '').to_i
  offer[:cost] = info.first.text.gsub(/\D/, '').to_i
  offer[:discount] = info[1].text.gsub(/\D/, '').to_i rescue 0
  offer[:ends_at] = $1 if timer.text =~ /targetDate:\s*"(.*)"/
  offer[:image] = open( @url + pattern.css('.slider-overview img').first['src'] )
  offer[:description] = pattern.css('#s1-tab-about').to_html
  offer[:city_id] = city.id
  offer[:country_id] = city.country_id
  offer[:subway] = subways.join("||")
  offer[:address] = addresses.join("||")

  offer[:subway] = nil if offer[:subway].blank?
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


@log.info "Finished parsing fun2mass. Total of #{saved} new offers were added"
