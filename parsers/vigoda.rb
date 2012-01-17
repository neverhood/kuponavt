# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

PROVIDER = Provider.where(name: 'vigoda').first

cities = {
  City.where(name: 'moskva').first => 'http://vigoda.ru/',
  City.where(name: 'sankt-peterburg').first => 'http://spb.vigoda.ru/all',
  City.where(name: 'almetyevsk').first => 'http://almetevsk.vigoda.ru/all',
  City.where(name: 'arkhangelsk').first => 'http://arhangelsk.vigoda.ru/all',
  City.where(name: 'astrakhan').first => 'http://astrahan.vigoda.ru/all',
  City.where(name: 'barnaul').first => 'http://barnaul.vigoda.ru/all',
  City.where(name: 'bryansk').first => 'http://bryansk.vigoda.ru/all',
  City.where(name: 'vladivostok').first => 'http://vladivostok.vigoda.ru/all',
  City.where(name: 'volgograd').first => 'http://volgograd.vigoda.ru/all',
  City.where(name: 'volzhsky').first => 'http://volzhskiy.vigoda.ru/all',
  City.where(name: 'vologda').first => 'http://vologda.vigoda.ru/all',
  City.where(name: 'voronezh').first => 'http://voronezh.vigoda.ru/all',
  City.where(name: 'yekaterinburg').first => 'http://ekaterinburg.vigoda.ru/all',
  City.where(name: 'ivanovo').first => 'http://ivanovo.vigoda.ru/all',
  City.where(name: 'izhevsk').first => 'http://ijevsk.vigoda.ru/all',
  City.where(name: 'irkutsk').first => 'http://irkutsk.vigoda.ru/all',
  City.where(name: 'yoshkar-ola').first => 'http://yoshkarola.vigoda.ru/all',
  City.where(name: 'mineralnye-vody').first => 'http://minvod.vigoda.ru/all',
  City.where(name: 'kazan').first => 'http://kazan.vigoda.ru/all',
  City.where(name: 'kaliningrad').first => 'http://kaliningrad.vigoda.ru/all',
  City.where(name: 'kaluga').first => 'http://kaluga.vigoda.ru/all',
  City.where(name: 'kemerovo').first => 'http://kemerovo.vigoda.ru/all',
  City.where(name: 'kirov').first => 'http://kirov.vigoda.ru/all',
  City.where(name: 'kostroma').first => 'http://kostroma.vigoda.ru/all/',
  City.where(name: 'krasnodar').first => 'http://krasnodar.vigoda.ru/all/',
  City.where(name: 'krasnoyarsk').first => 'http://krasnoyarsk.vigoda.ru/all/',
  City.where(name: 'kursk').first => 'http://kursk.vigoda.ru/all/',
  City.where(name: 'lipetsk').first => 'http://lipetsk.vigoda.ru/all/',
  City.where(name: 'magnitogorsk').first => 'http://magnitogorsk.vigoda.ru/all/',
  City.where(name: 'murmansk').first => 'http://murmansk.vigoda.ru/all/',
  City.where(name: 'naberezhnye-chelny').first => 'http://naberezhnye_chelny.vigoda.ru/all/',
  City.where(name: 'nizhnekamsk').first => 'http://nizhnekamsk.vigoda.ru/all/',
  City.where(name: 'nijnii-novgorod').first => 'http://nnovgorod.vigoda.ru/all/',
  City.where(name: 'veliky-novgorod').first => 'http://vnovgorod.vigoda.ru/all/',
  City.where(name: 'novokuznetsk').first => 'http://novokuznetsk.vigoda.ru/all/',
  City.where(name: 'novosibirsk').first => 'http://novosibirsk.vigoda.ru/all/',
  City.where(name: 'norilsk').first => 'http://norilsk.vigoda.ru/all/',
  City.where(name: 'omsk').first => 'http://omsk.vigoda.ru/all/',
  City.where(name: 'orel').first => 'http://orel.vigoda.ru/all/',
  City.where(name: 'penza').first => 'http://penza.vigoda.ru/all/',
  City.where(name: 'perm').first => 'http://perm.vigoda.ru/all/',
  City.where(name: 'petrozavodsk').first => 'http://petrozavodsk.vigoda.ru/all/',
  City.where(name: 'petropavlovsk-kamchatsky').first => 'http://kamchatka.vigoda.ru/all/',
  City.where(name: 'pskov').first => 'http://pskov.vigoda.ru/all/',
  City.where(name: 'rostov-na-donu').first => 'http://rostovnadonu.vigoda.ru/all/',
  City.where(name: 'ryazan').first => 'http://ryazan.vigoda.ru/all/',
  City.where(name: 'salekhard').first => 'http://salekh.vigoda.ru/all/',
  City.where(name: 'samara').first => 'http://samara.vigoda.ru/all/',
  City.where(name: 'saratov').first => 'http://saratov.vigoda.ru/all/',
  City.where(name: 'smolensk').first => 'http://smolensk.vigoda.ru/all/',
  City.where(name: 'sochi').first => 'http://sochi.vigoda.ru/all/',
  City.where(name: 'surgut').first => 'http://surgut.vigoda.ru/all/',
  City.where(name: 'siktivkar').first => 'http://syiktyivkar.vigoda.ru/all/',
  City.where(name: 'tver').first => 'http://tver.vigoda.ru/all/',
  City.where(name: 'tolyatti').first => 'http://tlt.vigoda.ru/all/',
  City.where(name: 'tomsk').first => 'http://tomsk.vigoda.ru/all/',
  City.where(name: 'tula').first => 'http://tula.vigoda.ru/all/',
  City.where(name: 'tyumen').first => 'http://tumen.vigoda.ru/all/',
  City.where(name: 'ulan-ude').first => 'http://ulan.vigoda.ru/all/',
  City.where(name: 'ulyanovsk').first => 'http://ulyan.vigoda.ru/all/',
  City.where(name: 'ufa').first => 'http://ufa.vigoda.ru/all/',
  City.where(name: 'khabarovsk').first => 'http://habarovsk.vigoda.ru/all/',
  City.where(name: 'hantimansiysk').first => 'http://hantmans.vigoda.ru/all/',
  City.where(name: 'cheboksary').first => 'http://cheboksary.vigoda.ru/all/',
  City.where(name: 'cheliabinsk').first => 'http://chelyabinsk.vigoda.ru/all/',
  City.where(name: 'cherepovets').first => 'http://cherepovets.vigoda.ru/all/',
  City.where(name: 'chita').first => 'http://chita.vigoda.ru/all/',
  City.where(name: 'yuzhno-sahalinsk').first => 'http://yuzhnosah.vigoda.ru/all/',
  City.where(name: 'yakutsk').first => 'http://yakutsk.vigoda.ru/all/',
  City.where(name: 'yaroslavl').first => 'http://yaroslavl.vigoda.ru/all/',
  City.where(name: 'kiev').first => 'http://kiev.vigoda.ru/all',
  City.where(name: 'dnepropetrovsk').first => 'http://dnepropetrovsk.vigoda.ru/all/',
  City.where(name: 'donetsk').first => 'http://donezk.vigoda.ru/all/',
  City.where(name: 'zaporozhye').first => 'http://zaporogie.vigoda.ru/all/',
  City.where(name: 'ivano-frankovsk').first => 'http://ivanovofrankovsk.vigoda.ru/all/',
  City.where(name: 'lugansk').first => 'http://lugansk.vigoda.ru/all/',
  City.where(name: 'lvov').first => 'http://lvov.vigoda.ru/all/',
  City.where(name: 'nikolaev').first => 'http://nikolaev.vigoda.ru/all/',
  City.where(name: 'odessa').first => 'http://odessa.vigoda.ru/all/',
  City.where(name: 'poltava').first => 'http://poltava.vigoda.ru/all/',
  City.where(name: 'sevastopol').first => 'http://sevastopol.vigoda.ru/all/',
  City.where(name: 'ternopol').first => 'http://ternolpol.vigoda.ru/all/',
  City.where(name: 'kharkov').first => 'http://kharkov.vigoda.ru/all/',
  City.where(name: 'kherson').first => 'http://herson.vigoda.ru/all/',
  City.where(name: 'chernigov').first => 'http://chernigov.vigoda.ru/all/'
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
