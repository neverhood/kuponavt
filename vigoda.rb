# encoding: UTF-8
require 'open-uri'

PROVIDER = Provider.where(name: 'vigoda').first

cities = {
  City.where(name: 'kiev').first => 'http://kiev.vigoda.ru',
  City.where(name: 'moskva').first => 'http://vigoda.ru'
}

bot = Mechanize.new
#xml_offers = Nokogiri::XML( open 'http://vigoda.ru/api/xml' ).xpath('//offer')

categories = {
  '/cafe' => 2,
  '/beauty' => 11,
  '/health' => 10,
  '/products' => 16,
  '/fitness' => 12,
  '/auto' => 18,
  '/education' => 14,
  '/events' => 3,
  '/children' => 20,
  '/rest' => nil,
  '/services' => nil
}


cities.keys.each do |city|
  existing_offers_ids = city.offers.where(:provider_id => PROVIDER.id).map(&:provided_id)

  bot.get cities[city]

  categories.keys.each do |category|
    bot.get category

    offers = []
    offer_links = bot.page.links_with(:href => /offer/).map(&:href).uniq.map { |uri| uri.gsub /%.*/, '' }

    offer_links.each do |link|
      provided_id = $1.to_i if link =~ /\/(\d+)\//

      if existing_offers_ids.include?(provided_id.to_s)
        existing_offers_ids -= [provided_id.to_s]
        next
      end

      params = Hash[[
        [:provided_id, provided_id],
        [:url, link.gsub(/\/$/, '') + PROVIDER.ref_url], [:city_id, city.id ], [:country_id, city.country.id],
        [:provider_id, PROVIDER.id]
      ]]
      #offer_xml = xml_offers.find { |o| o.xpath('url').text.include? provided_id.to_s }

      bot.get link
      parser = lambda { |selector| bot.page.parser.css selector }

      params[:title] = parser.call('table.content div .pointer-hand').first.text.strip
      params[:price] = parser.call('div.main-buy-label div.pointer-hand div').first
      next if params[:price].nil?
      params[:price] = params[:price].text.gsub(',','').to_i if params[:price]
      if params[:price] == 0 # STARTS_AT
        params[:price] = nil
        params[:price_starts_at] = parser.call('div.main-buy-label div.pointer-hand div')[1].text.gsub(',','').to_i
      end
      params[:cost] = parser.call('td.price-discount-profit td div').first.text.strip.gsub(',','').to_i
      params[:discount] = parser.call('td.price-discount-profit td div')[1].text.strip.to_i
      begin
        params[:image] = open(parser.call('img.pointer-hand').first[:src])
      rescue Exception => e
        params[:image] = nil
      end
      #params[:description] = parser.call('div.conditions').inner_html.strip
      offer_desc = parser.call('div.conditions')
      offer_desc.css('a').each do |a|
        a['target'] = '_blank'
        a['rel'] = 'nofollow'
      end
      params[:description] = offer_desc.to_html.strip
      params[:address] = $1 if parser.call('.main-benefits-right').text =~ /Основной адрес:\s*(.*)\s*, Тел/
#      params[:ends_at] = (Time.parse(offer_xml.xpath('endsell').text.gsub('T',' ')) + 1) if offer_xml

      offers << params
    end

    offers.each do |offer_attributes|
      Offer.create(offer_attributes) ||
        CrawlingException.create(provider_id: PROVIDER.id, error_text: 'failed to save offer', offer_attributes: offer_attributes)
    end

  end
  if existing_offers_ids.any?
    Offer.where(provided_id: existing_offers_ids).each do |offer|
      OfferArchive.create( offer.attributes.merge({archived_at: Time.now}) )
      offer.destroy
      offer = nil # garbage
    end
  end

end