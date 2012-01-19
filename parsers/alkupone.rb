require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

@provider = PROVIDER = Provider.where(:name => 'alkupone').first
@existing_offers = Offer.where(provider_id: @provider.id).map(&:provided_id)
@log = Logger.new(File.expand_path('../logs/alkupone.log', __FILE__))
@bot = Mechanize.new
@url = 'http://alkupone.ru'

@log.info("Starting alkupone parser: #{Time.now} ... ")

@bot.get(@url)

offers_per_page = 21
total_offers = @bot.page.parser.css('ul.categories li span').first.text.to_i
last_page = (total_offers % offers_per_page) == 0 ? total_offers/offers_per_page : (total_offers/offers_per_page) + 1
pages = (2..last_page)

city = City.find_by_name('moskva')
offers = []
saved_offers = []
saved = 0

@bot.page.parser.css('.deal h3 a').each { |a| offers << { url: a['href'], provided_id: a['href'].gsub(/.*\//, '') } }

pages.each do |page|
  @bot.get("/?category=undefined&page=#{page}&sort=date&_=hello_world")
  @bot.page.parser.css('.deal h3 a').each { |a| offers << { url: a['href'], provided_id: a['href'].gsub(/.*\//, '') } }
end

offers.each do |offer|

  if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
    @log.info("Skipping existing offer: #{offer[:provided_id]}")
    @existing_offers.delete(offer[:provided_id])
    offer = nil
    next
  end

  @bot.get offer[:url]

  pattern = @bot.page.parser.css('.deal')
  contacts = @bot.page.parser.css('.contacts ul')[1].css('li') rescue nil
  raw_description = @bot.page.parser.css('.text.about')
  raw_description.css('img').each do |img|
    img['src'] = @url + img['src']
  end

  offer[:provider_id] = @provider.id
  offer[:city_id] = city.id
  offer[:country_id] = city.country_id
  offer[:title] = pattern.css('h1').first.children.first.text.strip
  offer[:discount] = pattern.css('td.nominal').first.next.next.text.to_i
  offer[:price] = pattern.css('.price').first.text.gsub(/\D/, '').to_i
  offer[:cost] = pattern.css('td.nominal').first.text.gsub(/\D/, '').to_i
  offer[:image] = open( @url + pattern.css('.pictures img').first['src'] )
  offer[:address] = contacts.first.text.strip if contacts
  offer[:subway] = contacts.last.text.strip if contacts
  offer[:ends_at] = (@bot.page.parser.css('p.timer').first['data-until'].to_i/3600/24).days.from_now
  offer[:description] = description('alkupone.ru', raw_description).to_html

  offer[:address] = nil if offer[:address].blank?
  offer[:subway] = nil if offer[:subway].blank?

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

  @bot = Mechanize.new

end

@existing_offers.each do |expired_offer|
  @log.info("Removing expired offer #{expired_offer}")
  Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
end


@log.info "Finished parsing alkupone. Total of #{saved} new offers were added"

