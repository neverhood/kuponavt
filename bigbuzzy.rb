# encoding: UTF-8
require 'pry'
require 'nokogiri'
require 'open-uri'

PROVIDER = Provider.find_by_name('bigbuzzy')

cities = City.where(name: ['moskva'])
offers = Nokogiri::XML( open 'http://bigbuzzy.ru/xml/' ).xpath('//offer')

categories_mapping = {
  'leisure' => 3,
  'beauty' => 11,
  'food' => 2,
  'sport' => 12,
  'education' => 14,
  'health' => 10,
  'auto' => 18,
  'products' => 16,
  'tourism' => 8,
  'child' => 20,
  'other' => 24
}

cities_mapping = {
  'moscow' => 'Москва'
}

cities.each do |city|
  city_offer_attributes = []
  city_offers = offers.select { |offer| offer.xpath('region').text == cities_mapping[city.name] }
  binding.pry

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
      country_id: city.country_id,
      category_id: categories_mapping[offer.xpath('category').text]
    }

    city_offer_attributes << offer_attributes unless Offer.where(provider_id: PROVIDER.id, provided_id: offer_attributes[:provided_id]).any?

  end

  city_offer_attributes.each do |city_offer_attributes|
    offer = Offer.new( city_offer_attributes )
    if offer.valid?
      offer.save
    else
      binding.pry
    end
  end
end
