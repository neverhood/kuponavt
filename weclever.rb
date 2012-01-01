# encoding: UTF-8
require 'nokogiri'
require 'open-uri'
require 'pry'

URL = 'http://www.weclever.ru/xml/openstat/kuponavt.com.xml'
PROVIDER = Provider.find_by_name('weclever')

cities = City.where(name: ['moscow'])
offers = Nokogiri::XML( open URL ).xpath('//offer')

cities_mapping = {
  moscow: 'Москва'
}

cities.each do |city|
  city_offer_attributes = []
  city_offers = offers.select { |offer| offer.xpath('region').text == cities_mapping[city.name.to_sym] }

  city_offers.each do |offer|

    offer_attributes = {
      title: offer.xpath('name').text,
      provider_id: PROVIDER.id,
      provided_id: offer.xpath('id').text,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text,
      ends_at: Time.parse(offer.xpath('endsell').text.gsub('T',' ')) + 1,
      image: open( offer.xpath('picture').text ),
      price: (offer.xpath('pricecoupon').text.to_i == 0 ? nil : offer.xpath('pricecoupon').text.to_i),
      cost: (offer.xpath('price').text.to_i == 0 ? nil : offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').text,
      city_id: city.id,
      country_id: city.country_id
    }

    city_offer_attributes << offer_attributes
    binding.pry

  end
end


