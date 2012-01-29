#require 'open-uri'
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

#OpenURI::Buffer::StringMax = 0

URL = 'http://www.biglion.ru/'
PROVIDER = Provider.where(:name => 'biglion').first

@log = Logger.new(File.expand_path('../logs/biglion.log', __FILE__))
@bot = Mechanize.new
image_bot = Mechanize.new

cities = {
  City.find_by_name('kiev') => 'kiev',
  City.find_by_name('moskva') => 'moscow',
  City.find_by_name('bryansk') => 'bryansk',
  City.find_by_name('vladivostok') => 'vladivostok',
  City.find_by_name('sankt-peterburg') => 'speterburg',
  City.find_by_name('vologda') => 'vologda',
  City.find_by_name('kazan') => 'kazan',
  City.find_by_name('kostroma') => 'kostroma',
  City.find_by_name('magnitogorsk') => 'magnitog',
  City.find_by_name('nijnii-novgorod') => 'nnovgorod',
  City.find_by_name('voronezh') => 'voronezh',
  City.find_by_name('kaliningrad') => 'kaliningrad',
  City.find_by_name('krasnodar') => 'krasnodar',
  City.find_by_name('makhachkala') => 'mkala',
  City.find_by_name('nizhnij-tagil') => 'ntagil',
  City.find_by_name('penza') => 'penza',
  City.find_by_name('saransk') => 'saransk',
  City.find_by_name('surgut') => 'surgit',
  City.find_by_name('tula') => 'tula',
  City.find_by_name('cheboksary') => 'cheb',
  City.find_by_name('yekaterinburg') => 'ekaterinburg',
  City.find_by_name('kaluga') => 'kaluga',
  City.find_by_name('krasnoyarsk') => 'krasnoyarsk',
  City.find_by_name('murmansk') => 'murmansk',
  City.find_by_name('novokuznetsk') => 'novokuznetsk',
  City.find_by_name('perm') => 'perm',
  City.find_by_name('saratov') => 'saratov',
  City.find_by_name('taganrog') => 'taganrog',
  City.find_by_name('tyumen') => 'tyumen',
  City.find_by_name('cheliabinsk') => 'chelyabinsk',
  City.find_by_name('ivanovo') => 'ivanovo',
  City.find_by_name('kemerovo') => 'kemerovo',
  City.find_by_name('kurgan') => 'kurgan',
  City.find_by_name('naberezhnye-chelny') => 'nabchelny',
  City.find_by_name('novosibirsk') => 'novosibirsk',
  City.find_by_name('petrozavodsk') => 'petrozavodsk',
  City.find_by_name('smolensk') => 'smolensk',
  City.find_by_name('tambov') => 'tambov',
  City.find_by_name('ulan-ude') => 'ulan-ude',
  City.find_by_name('cherepovets') => 'cherepov',
  City.find_by_name('izhevsk') => 'izh',
  City.find_by_name('kirov') => 'kirov',
  City.find_by_name('kursk') => 'kursk',
  City.find_by_name('nalchik') => 'nalchik',
  City.find_by_name('omsk') => 'omsk',
  City.find_by_name('rostov-na-donu') => 'rostovnadonu',
  City.find_by_name('sochi') => 'sochi',
  City.find_by_name('tver') => 'tver',
  City.find_by_name('ulyanovsk') => 'ulyanovsk',
  City.find_by_name('chita') => 'chita',
  City.find_by_name('orenburg') => 'orenburg',
  City.find_by_name('samara') => 'samara',
  City.find_by_name('sterlitamak') => 'sterlitamak',
  City.find_by_name('tomsk') => 'tomsk',
  City.find_by_name('khabarovsk') => 'khabarovsk',
  City.find_by_name('yaroslavl') => 'yaroslavl',
  City.find_by_name('vladikavkaz') => 'vladikavkaz',
  City.find_by_name('arkhangelsk') => 'arkhangelsk',
  City.find_by_name('astrakhan') => 'astrakhan',
  City.find_by_name('vladimir') => 'vladimir',
  City.find_by_name('barnaul') => 'barnaul',
  City.find_by_name('volgograd') => 'volgograd',
  City.find_by_name('volzhsky') => 'volzhsky',
  City.find_by_name('belgorod') => 'belgorod',
  City.find_by_name('irkutsk') => 'irkutsk',
  City.find_by_name('komsomolsk-na-amure') => 'kms',
  City.find_by_name('lipetsk') => 'lipetsk',
  City.find_by_name('nizhnevartovsk') => 'nvartovsk',
  City.find_by_name('orel') => 'orel',
  City.find_by_name('ryazan') => 'ryazan',
  City.find_by_name('stavropol') => 'stavropol',
  City.find_by_name('tolyatti') => 'togliatti',
  City.find_by_name('ufa') => 'ufa',
  City.find_by_name('yakutsk') => 'yakutsk'
}

def parser(selector)
  @bot.page.parser.css(selector)
end

@log.info("Starting biglion parser: #{Time.now} ... ")
saved = 0

cities.keys.each do |city|

  #existing_offers = Offer.where(provider_id: PROVIDER.id, city_id: city.id).map(&:provided_id)
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
  @saved_offers = []

  @log.info("Going to city #{city.name}: #{URL + cities[city]}")
  @bot.get URL + cities[city]

  offers = []
  pagination = parser('div.main_pagination_block').count > 0 ? parser('div.main_pagination_block') : nil

  if pagination
    current_page = 1
    pages = (1..pagination.css('a').slice(0, pagination.css('a').length - 1).last.text.to_i).to_a

    pages.each do |page|
      page_url = parser('div.main_pagination_block a').find { |a| a.text == page.to_s }
      @bot.get page_url['href'] unless page == 1 

      parser('div.actionsItem').each do |pattern|
        offers << { provided_id: pattern['id'], url: pattern.css('div.actionsItemHeadding a').first['href'] }
      end
    end
  else
    parser('div.actionsItem').each do |pattern|
      offers << { provided_id: pattern['id'], url: pattern.css('div.actionsItemHeadding a').first['href'] }
    end
  end
  @bot = Mechanize.new

  offers.each do |offer|
    if existing_offers.include?(offer[:provided_id]) || @saved_offers.include?(offer[:provided_id])
      @log.info("Skipping existing offer: #{offer[:provided_id]}")
      existing_offers.delete(offer[:provided_id])
      offer = nil
      next
    end

    if Offer.where(provided_id: offer[:provided_id], provider_id: PROVIDER.id).any?
      existing_model = Offer.where(provided_id: offer[:provided_id], provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer[:url])
      @log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      existing_model = nil # garbage
      offer = nil
      next
    end

    @bot.get offer[:url]

    pattern = parser('div.single-box-pro')

    offer[:provider_id] = PROVIDER.id
    offer[:country_id] = city.country_id
    offer[:city_id] = city.id
    offer[:title] = pattern.css('h1').first.text
    offer[:price] = pattern.css('div.price-label div.num b').text.to_i
    offer[:cost] = pattern.css('table[1] td[1] b[1]').text.to_i rescue nil
    offer[:discount] = pattern.css('table[1] td[2] b[1]').text.to_i

    image = $1 if @bot.page.body =~ /image_big\s*=\s*"(.*)"/
    if image.nil?
      image = $1.split("\n")[1].strip.gsub("'", "") if @bot.page.body =~ /photos_big = \[\n(.*)/m
    end

    if image
      offer[:image] = open(image_bot.get(image.gsub(/,$/, '')).uri) rescue nil
      image_bot = Mechanize.new
    else
      offer[:image] = nil
    end
    offer[:address] = pattern.css('div.links div[1]').children.first.text.strip rescue nil
    offer[:subway] = pattern.css('div.links div[1] div').text.strip rescue nil
    offer[:subway] = nil if offer[:subway].blank? || offer[:subway].length >= 255

    description = pattern.css('div.ppOffer-info')
    description.css('a').each do |a|
      if a['href'] =~ /company\/faq/
        a.remove
      else
        a['target'] = '_blank'
        a['rel'] = 'nofollow'
      end
    end
    offer[:description] = description.to_html
    description = nil

    model = Offer.new(offer)
    if model.valid?
      city_clone = city.clone # city includes offers and raises as fuck ( memory )
      city_clone.offers << model
      @log.info("Saving offer: #{model.provided_id}")
      @saved_offers << model.provided_id
      saved += 1
      city_clone = nil # Not sure if it's needed
    else
      @log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
    end
    model = nil
    offer = nil
    @bot = Mechanize.new

  end

  existing_offers.each do |expired_offer|
    @log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end
  @log.info("Finished parsing #{city.name}. Total of #{@saved_offers.count} new offers saved, #{existing_offers.count} are expired and were deleted")
  offers = nil # Garbage
  existing_offers = nil
  @saved_offers = nil


end

@log.info "Finished parsing biglion. Total of #{saved} new offers were added"
