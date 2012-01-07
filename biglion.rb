require 'mechanize'
require 'pry'
require 'open-uri'

URL = 'http://www.biglion.ru/'
PROVIDER = Provider.where(:name => 'biglion').first

bot = Mechanize.new
image_bot = Mechanize.new

# auth_url = 'http://www.biglion.ru/auth/'
# auth_details = {
#   email_4: 'kupostat@gmail.com',
#   password_4: 'cdtnbr1988'
# }

cities = %w( kiev moscow )

matchers = {
  :pagination => '.main_pagination_block',
  :current_page => '.main_pagination_block .active',
  :pagination_links => '.main_pagination_block a',
  :offers => '.newActions .actionsItem'
}

categories = {
  :list => {
    '51' => 11,
    '52' => 10,
    '53' => 2,
    '55' => 12,
    '56' => 14,
    '57' => 18
  },
  :goods => {
    '13' => 16,
    '14' => 16,
    '18' => 16,
    '19' => 16,
    '15' => 11,
    '16' => 17,
    '17' => 20
  },
  :travel => {
    '4' => 8,
    '5' => 8,
    '6' => 8,
    '7' => 8
  }
}


def retrieve_price(offer) # This is redicolous...
  if offer.css('.price .num')
    price = $1.to_i if offer.css('.price .num').text =~ /(\d+)/

    if offer.css('.price .num .numstart').count > 0
      return( {price_starts_at: price} )
    else
      return( {price: price} )
    end
  end

  if offer.css('.priceToBuy')
    price = offer.css('.priceToBuy .pNewPrice').children.first.text.to_i
    retail_price = offer.css('.priceToBuy .pOldPrice').children.first.text.to_i

    return( {retail: true, price: price, retail_price: retail_price} )
  end
end

retrieve_attributes = lambda do |offers|
  attributes = []

  offers.each do |offer|
    offer_attributes = {}
    offer = offer.first if offer.is_a?(Nokogiri::XML::NodeSet)

    begin
      offer_attributes[:provided_id] = offer.css('.photo a').first.attr(:rel) || offer.attr('id') || offer.attr('data-id')

      if Offer.where(provided_id: offer_attributes[:provided_id], provider_id: PROVIDER.id).any?
        $existing_offers -= [ offer_attributes[:provided_id] ]
        next
      end

      offer_attributes[:url] = offer.css('.actionsItemHeadding a').first.attr(:href) + PROVIDER.ref_url

      bot.get offer_attributes[:url]
      offer = bot.page.parser.css('.offer').first
      img_url = (bot.page.parser.css('script').inner_html.scan(/photos_big\s*=\s*\[(.*)\]\;/m).flatten.
                 first.split(',').first.strip.gsub('\'', ''))

      if img_url.blank?
        img_url = bot.page.parser.css('script').inner_html.scan(/var image_big(.*);/)[0][0].gsub(/"/, '').gsub(/.*http/, 'http')
      end

      if img_url =~ /\n/
        img_url = img_url.split("\n").first.strip
      end

      offer_attributes[:image] = open( image_bot.get(img_url).uri ) unless img_url.blank?
      offer_attributes[:title] = offer.css('h1').text
      offer_attributes.merge! retrieve_price(offer)
      offer_attributes[:cost] = offer.css('table').last.css('tr td b').first.text.to_i
      if offer.css('table').last.css('tr td b')[1] #.text.to_i #NIL
        offer_attributes[:discount] = offer.css('table').last.css('tr td b')[1].text.to_i
      else
        offer_attributes[:discount] = offer_attributes[:cost]
        offer_attributes[:cost] = 0 # UNLIMITED
      end
      # bitches!!
      if offer.css('.offer-contact .links').count > 0
        offer_attributes[:subway] = offer.css('.offer-contact .links div div div').text.strip
        if offer.css('.offer-contact .links div div').first
          offer_attributes[:address] = offer.css('.offer-contact .links div div').first.children.first.text.strip
        end
      end

      offer.css('.ppOffer-info a').remove
      offer_attributes[:description] = offer.css('.ppOffer-info').inner_html
    rescue Exception => e
      binding.pry
    end

    attributes << offer_attributes

  end

  attributes

end

# bot.post(auth_url, auth_details)
cities.each do |city|


  city_model = City.where(name: city).first
  country_model = city_model.country

  $existing_offers = Offer.where(:city_id => city_model.id, :provider_id => PROVIDER.id).map(&:provided_id)

  base_url = "#{URL}/#{city}"
  bot.get base_url

  categories.keys.each do |category|
    category_url = "#{base_url}/#{category.to_s}"
    bot.get category_url

    if category == :list || category == :travel
      biglion_categories = bot.page.parser.css('.menu_item[data]').map { |c| c.attr :data }.
        keep_if { |element| element =~ /\d+/ }

      biglion_categories.each do |biglion_category|
        bot.get category_url

        offers = bot.page.parser.css(".actionsItem[data='#{biglion_category}']").to_ary
        offers << bot.page.parser.css(".currentActionsItem[data='#{biglion_category}']").to_ary

        biglion_offers = retrieve_attributes.call(offers.flatten)
        biglion_offers.each do |offer_attributes|
          offer_attributes.merge! category_id: categories[category][biglion_category], city_id: city_model.id,
            country_id: country_model.id, provider_id: PROVIDER.id
          Offer.create(offer_attributes) || binding.pry
        end
      end
    else
      # FUCKING STUPID!!!
      deal_offer_values = bot.page.parser.css('script').inner_html.scan(/deal_offer_values\s*=\s*(.*)/)[0][0].gsub(';','')
      offer_ids_to_category_ids = JSON.parse( deal_offer_values )

      offers = []
      offer_ids_to_category_ids.each do |offer_and_categories|
        offers << bot.page.parser.css("[data-id='#{offer_and_categories.first}']")
      end

      biglion_offers = retrieve_attributes.call(offers)
      biglion_offers.each do |offer_attributes|
        begin
          if offer_ids_to_category_ids[ offer_attributes[:provided_id] ]
            offer_categories = offer_ids_to_category_ids[ offer_attributes[:provided_id] ]
            offer_category = offer_categories.is_a?(Array) ? offer_categories.first : offer_categories
            if offer_category
              offer_attributes.merge! category_id: categories[category][offer_category]
            end
          end
          offer_attributes.merge! city_id: city_model.id, country_id: country_model.id, provider_id: PROVIDER.id
          Offer.create(offer_attributes) || binding.pry
        rescue
          binding.pry
        end
      end
    end

  end

  if $existing_offers.any?
    Offer.where(:provider_id => PROVIDER.id, :provided_id => $existing_offers).delete_all
  end

end
