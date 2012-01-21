# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

URL = 'http://ladykupon.ru/kuponator.xml'
PROVIDER = Provider.find_by_name('ladykupon')

log = Logger.new(File.expand_path('../logs/ladykupon.log', __FILE__))

cities = {
  City.find_by_name('moskva') => 'Москва'
}
xml_offers = Nokogiri::XML( open URL ).xpath('//offer')
saved = 0

log.info("Starting ladykupon parser: #{Time.now}")

cities.keys.each do |city|
  log.info("Processing #{city.name} offers")

  offer_attributes, saved_offers = [], []
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
#  city_offers = xml_offers.select { |offer| offer.xpath('region').text == cities[city] }
  city_offers = []
  xml_offers.map do |offer|
    if offer.xpath('region').text == city.russian_name
      city_offers << offer
      nil
    else
      offer
    end
  end
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
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer.xpath('url').text)
      log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      existing_model = nil
      next
    end

    binding.pry if Offer.where(title: offer.xpath('name').text, provider_id: PROVIDER.id).any?

    offer_attributes = {
      title: offer.xpath('name').text,
      provider_id: PROVIDER.id,
      provided_id: offer.xpath('id').text,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text.gsub("\n", "<br />").gsub("\t", ""),
      ends_at: Time.parse(offer.xpath('endsell').text.gsub('T',' ')) + 1,
      image: open( offer.xpath('picture').text ),
      price: offer.xpath('pricecoupon').text.to_i,
      cost: (offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').map(&:text).map(&:strip).join("||"),
      coordinates: offer.xpath('supplier/addresses/address/coordinates').map(&:text).join("||"),
      country_id: city.country_id,
      city_id: city.id
    }
    offer_attributes[:price] = offer.xpath('discountprice').text.to_i if offer_attributes[:price] == 0
    offer_attributes[:coordinates] = nil if offer_attributes[:coordinates].blank?
    offer_attributes[:address] = nil if offer_attributes[:address].blank?

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

log.info("Finished weclever parser. #{saved} offers added. #{Time.now}")

