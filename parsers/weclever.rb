# encoding: UTF-8
require 'open-uri'
require 'pry'

URL = 'http://www.weclever.ru/xml/openstat/kuponavt.com.xml'
PROVIDER = Provider.find_by_name('weclever')

log = Logger.new(File.expand_path('../logs/weclever.log', __FILE__))

cities = {
  City.find_by_name('moskva') => 'Москва',
  City.find_by_name('sankt-peterburg') => 'Санкт-Петербург',
  City.find_by_name('nijnii-novgorod') => 'Нижний Новгород',
  City.find_by_name('samara') => 'Самара',
  City.find_by_name('yekaterinburg') => 'Екатеринбург',
  City.find_by_name('novosibirsk') => 'Новосибирск',
  City.find_by_name('kazan') => 'Казань',
  City.find_by_name('krasnoyarsk') => 'Красноярск',
  City.find_by_name('rostov-na-donu') => 'Ростов-на-Дону',
  City.find_by_name('cheliabinsk') => 'Челябинск',
  City.find_by_name('arkhangelsk') => 'Архангельск',
  City.find_by_name('ufa') => 'Уфа',
  City.find_by_name('volgograd') => 'Волгоград',
  City.find_by_name('krasnodar') => 'Краснодар',
  City.find_by_name('omsk') => 'Омск',
  City.find_by_name('sochi') => 'Сочи',
  City.find_by_name('perm') => 'Пермь',
  City.find_by_name('saratov') => 'Саратов',
  City.find_by_name('izhevsk') => 'Ижевск',
  City.find_by_name('ulyanovsk') => 'Ульяновск',
  City.find_by_name('orenburg') => 'Оренбург',
  City.find_by_name('penza') => 'Пенза',
  City.find_by_name('naberezhnye-chelny') => 'Набережные Челны',
  City.find_by_name('barnaul') => 'Барнаул',
  City.find_by_name('irkutsk') => 'Иркутск',
  City.find_by_name('novokuznetsk') => 'Новокузнецк',
  City.find_by_name('kemerovo') => 'Кемерово',
  City.find_by_name('tomsk') => 'Томск',
  City.find_by_name('tyumen') => 'Тюмень',
  City.find_by_name('voronezh') => 'Воронеж',
  City.find_by_name('yaroslavl') => 'Ярославль',
  City.find_by_name('lipetsk') => 'Липецк',
  City.find_by_name('tula') => 'Тула',
  City.find_by_name('astrakhan') => 'Астрахань',
  City.find_by_name('kaliningrad') => 'Калининград',
  City.find_by_name('tolyatti') => 'Тольятти'
}
xml_offers = Nokogiri::XML( open URL ).xpath('//offer')
saved = 0

log.info("Starting weclever parser: #{Time.now}")

cities.keys.each do |city|
  log.info("Processing #{city.name} offers")

  offer_attributes, saved_offers = [], []
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
  city_offers = xml_offers.select { |offer| offer.xpath('region').text == cities[city] }

  log.info("Found #{city_offers.count} offers")

  city_offers.each do |offer|
    provided_id = offer.xpath('id').text

    if existing_offers.include?(provided_id) || saved_offers.include?(provided_id)
      log.info("Skipping existing offer: #{offer.xpath('id').text}")
      existing_offers.delete(provided_id)
      next
    end

    if Offer.where(provided_id: provided_id, provider_id: PROVIDER.id).any?
      existing_model = Offer.where(provided_id: provided_id, provider_id: PROVIDER.id).first
      existing_model.cities << city
      log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      next
    end

    offer_attributes = {
      title: offer.xpath('name').text,
      provider_id: PROVIDER.id,
      provided_id: offer.xpath('id').text,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text,
      ends_at: Time.parse(offer.xpath('endsell').text.gsub('T',' ')) + 1,
      image: open( offer.xpath('picture').text ),
      price: offer.xpath('pricecoupon').text.to_i,
      cost: (offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').text
    }
    offer_attributes[:price] = offer.xpath('discountprice').text.to_i if offer_attributes[:price] == 0

    model = Offer.new( offer_attributes )
    if model.valid?
      log.info("Saving offer #{provided_id}")
      city.offers << model
      saved_offers << model.provided_id
      saved += 1
    else
      log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
      binding.pry
    end

    existing_offers.each do |expired_offer|
      log.info("Removing expired offer #{expired_offer}")
      Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
    end

  end

  log.info("Finished processing #{city.name} ( #{Time.now} ). Saved #{saved_offers.count} new offers")
end

log.info("Finished weclever parser. #{saved} offers added. #{Time.now}")


