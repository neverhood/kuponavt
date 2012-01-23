# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

URL = 'http://www.kupikupon.ru/api/deals.xml'
PROVIDER = Provider.find_by_name('kupikupon')

log = Logger.new(File.expand_path('../logs/kupikupon.log', __FILE__))

xml_offers = Nokogiri::XML( open URL ).xpath('//deal')
saved = 0

cities = ["Москва",
          "Волгоград",
          "Санкт-Петербург",
          "Екатеринбург",
          "Нижний Новгород",
          "Новосибирск",
          "Тюмень",
          "Ростов-на-Дону",
          "Пермь",
          "Красноярск",
          "Самара",
          "Саратов",
          "Челябинск",
          "Уфа",
          "Омск",
          "Воронеж",
          "Магнитогорск",
          "Тольятти",
          "Краснодар",
          "Казань"]

log.info("Starting weclever parser: #{Time.now}")

cities.each do |city|
  city = City.find_by_russian_name( city )
  log.info("Processing #{city.name} offers")

  offer_attributes, saved_offers = [], []
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
#  city_offers = xml_offers.select { |offer| offer.xpath('region').text == cities[city] }
  city_offers = []
  xml_offers.map do |offer|
    if offer.xpath('city').text.strip == city.russian_name
      city_offers << offer
      nil
    else
      offer
    end
  end
  log.info("Found #{city_offers.count} offers")

  city_offers.each do |offer|
    provided_id = offer['id']

    if existing_offers.include?(provided_id) || saved_offers.include?(provided_id)
      log.info("Skipping existing offer: #{offer.xpath('id').text}")
      existing_offers.delete(provided_id)
      next
    end

    if Offer.where(title: offer.xpath('title').text.strip, provider_id: PROVIDER.id).any?
      existing_model = Offer.where(title: offer.xpath('title').text.strip, provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer.xpath('url').text)
      log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      existing_model = nil
      next
    end

    if Offer.where(provided_id: provided_id, provider_id: PROVIDER.id).any?
      existing_model = Offer.where(provided_id: provider_id,  provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer.xpath('url').text)
      log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      existing_model = nil
      next
    end

    binding.pry if Offer.where(title: offer.xpath('title').text.strip, provider_id: PROVIDER.id).any?

    offer_attributes = {
      title: offer.xpath('title').text.strip,
      provider_id: PROVIDER.id,
      provided_id: provided_id,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text.strip.gsub(/\s+/, " "),
      ends_at: Time.parse(offer.xpath('end_date').text),
      image: open( offer.xpath('image').text ),
      price: offer.xpath('price').text.to_i,
      cost: (offer.xpath('value').text.to_i),
      discount: offer.xpath('discount_percent').text.to_i,
      coordinates: "#{offer.xpath('latitude').text},#{offer.xpath('longitude').text}",
      country_id: city.country_id,
      city_id: city.id
    }
    contacts = Nokogiri::HTML(offer.xpath('contacts').first.text).text.gsub(/\+.*/m, '').split("\n").map(&:strip).
      delete_if { |s| s.blank? }
    offer_attributes[:address] = contacts[0]
    offer_attributes[:subway] = contacts[1]

    offer_attributes[:subway] = nil if offer_attributes[:address] =~ /Москва$/i ||
      offer_attributes[:subway] =~ /дом|офис|улица|телефон|Время работы|\d+/i

    offer_attributes[:coordinates] = nil if offer_attributes[:coordinates].blank?
    offer_attributes[:address] = nil if offer_attributes[:address].blank?

    binding.pry
    model = Offer.new( offer_attributes )
    if model.valid?
      log.info("Saving offer #{provided_id}")
      city.offers << model
      saved_offers << model.provided_id
      saved += 1
    else
      log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
    end

  end

  existing_offers.each do |expired_offer|
    log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end

  log.info("Finished processing #{city.name} ( #{Time.now} ). Saved #{saved_offers.count} new offers")
  city_offers = nil # Garbage
end

log.info("Finished planet_eds parser. #{saved} offers added. #{Time.now}")

