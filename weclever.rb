# encoding: UTF-8
require 'mechanize'
require 'open-uri'
require 'pry'

URL = 'http://www.weclever.ru/xml/openstat/kuponavt.com.xml'
PROVIDER = Provider.find_by_name('weclever')

bot = Mechanize.new

cities = City.where(name: ['moskva'])
offers = Nokogiri::XML( open URL ).xpath('//offer')

cities_mapping = {
  moscow: 'Москва'
}

categories_mapping = {
  'beauty' => 11,
  'food' => 2,
  'entertainment' => 3,
  'auto' => 18,
  'health' => 10,
  'tourism' => 8,
  'others' => 24
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
      cost: (offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').text,
      city_id: city.id,
      country_id: city.country_id
    }

    city_offer_attributes << offer_attributes unless Offer.where(provider_id: PROVIDER.id, provided_id: offer_attributes[:provided_id]).any?
    binding.pry

  end
end


