require 'open-uri'

OpenURI::Buffer::StringMax = 0

URL = 'http://www.skidkaest.ru'
PROVIDER = Provider.find_by_name 'skidkaest'

cities = Hash[[
  [ City.find_by_name('moskva'), '/city/1/gender/all/type/all' ],
  [ City.find_by_name('sankt-peterburg'), '/city/2/gender/all/type/all' ],
  [ City.find_by_name('volgograd'), '/city/15/gender/all/type/all' ],
  [ City.find_by_name('yekaterinburg'), '/city/6/gender/all/type/all' ],
  [ City.find_by_name('kazan'), '/city/8/gender/all/type/all' ],
  [ City.find_by_name('nijnii-novgorod'), '/city/7/gender/all/type/all' ],
  [ City.find_by_name('novosibirsk'), '/city/5/gender/all/type/all' ],
  [ City.find_by_name('omsk'), '/city/10/gender/all/type/all' ],
  [ City.find_by_name('perm'), '/city/14/gender/all/type/all' ],
  [ City.find_by_name('rostov-na-donu'), '/city/12/gender/all/type/all' ],
  [ City.find_by_name('samara'), '/city/9/gender/all/type/all' ],
  [ City.find_by_name('ufa'), '/city/13/gender/all/type/all' ],
  [ City.find_by_name('cheliabinsk'), '/city/11/gender/all/type/all' ]
]]

@bot = Mechanize.new
#@bot.get(url + all)

def parser(selector)
  @bot.page.parser.css(selector)
end

log = Logger.new(File.expand_path('../logs/skidkaest.log', __FILE__))
log.info("Starting 'skidkaest' parser...\n #{Time.now}")

cities.keys.each do |city|

  log.info("Going to city #{city.name}: #{URL + cities[city]}")
  saved = 0

  @bot.get URL + cities[city]
  offers = []
  existing_offers = Offer.where(provider_id: PROVIDER.id, city_id: city.id).map(&:provided_id)

  parser('section.catalog-item').each { |pattern| offers << { :provided_id => pattern['id'].gsub('offer-', '') } }
  offers.each do |offer|
    offer[:url] = 'http://www.skidkaest.ru/offers/index/view/id/' << offer[:provided_id]
  end

  offers.each do |offer|
    begin
      if existing_offers.include? offer[:provided_id]
        log.info("Ignoring existing offer #{offer[:provided_id]}")
        existing_offers.delete(offer[:provided_id])
        next
      else
        log.info("Going to crawl offer: #{offer[:url]}")
        @bot.get(offer[:url])
      end
    rescue Exception
      log.error("Wasn't able to get to: #{offer[:url]}")
      next
    end

    # Main
    offer[:title] = parser('section#site-content header.offer-cupon-header').text
    offer[:price] = parser('div.offer-price strong').first.text.to_i
    offer[:discount] = parser('div.item-discount span').text.gsub(/\D/, '').to_i
    offer[:cost] = parser('div.item-price strong').text.gsub(/\D/, '').to_i
    #offer[:image] = open( URL + parser('span.slideshow img').first['src'] ) rescue binding.pry
    parser('span.slideshow img').each do |img|
      begin
        offer[:image] = open( URL + img['src'] )
      rescue
        next
      end
    end
    offer[:city_id] = city.id
    offer[:country_id] = city.country.id
    offer[:provider_id] = PROVIDER.id

    # Contacts
    contacts = parser('div.cupon-contacts p')
    offer[:address] = contacts[1].text rescue nil
    offer[:subway] = contacts[2].text rescue nil

    # Description
    description = parser('div.about-cupon-content')
    description.css('img').remove
    description.css('a').each do |a|
      a['target'] = '_blank'
      a['rel'] = 'nofollow'
    end
    offer[:description] = description.to_html

    # Time left
    timer = parser("#offer-timer-#{offer[:provided_id]}")
    ends_at = timer.css('.timer-days') ? ( timer.css('.timer-days strong').text.to_i + 1 ) : 1
    offer[:ends_at] = ends_at.days.from_now.to_date

    model = Offer.new(offer)
    if model.valid?
      log.info("saving offer: \n #{offer[:provided_id]}")
      model.save
      saved += 1
      existing_offers << model.provided_id
    else
      log.error("can't save invalid offer: \n #{model.errors.full_messages.join(',')}")
    end

  end

  if existing_offers.any?
    log.info("Going to delete expired offers: #{existing_offers.join(',')}")
    log.info("Expired total: #{existing_offers.count}")
    Offer.where(provider_id: PROVIDER.id, provided_id: existing_offers).each { |offer| offer.destroy }
  else
    log.info("Everything is up to date")
  end

  log.info("FINISHED parsing city #{city.name}. #{saved} offers were saved to db. #{existing_offers.count} offers are expired and were deleted")

end

