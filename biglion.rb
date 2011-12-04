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

cities = %w( moscow )

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

  },
  :travel => {}
}
categories = {
  :list => {},
  :goods => {},
  :travel => {}
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

    offer_attributes[:provided_id] = offer.css('.photo a').first.attr(:rel) || offer.attr(:id)

    next if Offer.where(provided_id: offer_attributes[:provided_id], provider_id: PROVIDER.id).any?

    offer_attributes[:url] = offer.css('.actionsItemHeadding a').first.attr :href

    bot.get offer_attributes[:url]
    offer = bot.page.parser.css('.offer').first
    img_url = (bot.page.parser.css('script').inner_html.scan(/photos_big\s*=\s*\[(.*)\]\;/m).flatten.
      first.split(',').first.strip.gsub('\'', ''))

    if img_url.blank?
      img_url = bot.page.parser.css('script').inner_html.scan(/var image_big(.*);/)[0][0].gsub(/"/, '').gsub(/.*http/, 'http')
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
    offer_attributes[:subway] = offer.css('.offer-contact .links div div div').text.strip
    offer_attributes[:address] = offer.css('.offer-contact .links div div').first.children.first.text.strip
    offer_attributes[:ends_at] = offer.css('.ppOffer-info ul li span').first.text.gsub(/[^\.\d]/, '')
    offer_attributes[:description] = offer.css('.ppOffer-info').inner_html

    attributes << offer_attributes

  end

  attributes

end

# bot.post(auth_url, auth_details)

cities.each do |city|

  city_model = City.where(name: city).first
  country_model = city_model.country

  base_url = "#{URL}/#{city}"
  bot.get base_url

  categories.keys.each do |category|
    category_url = "#{base_url}/#{category.to_s}"
    bot.get category_url

    if category == :list
      biglion_categories = bot.page.parser.css('.menu_item[data]').map { |c| c.attr :data }.
        keep_if { |element| element =~ /\d+/ }

      biglion_categories.each do |biglion_category|
        bot.get category_url

        offers = bot.page.parser.css(".actionsItem[data='#{biglion_category}']").to_ary
        offers << bot.page.parser.css(".currentActionsItem[data='#{biglion_category}']").to_ary

        biglion_offers = retrieve_attributes.call(offers.flatten)
        biglion_offers.each do |offer_attributes|
          binding.pry
          offer_attributes.merge! category_id: categories[category][biglion_category], city_id: city_model.id,
            country_id: country_model.id, provider_id: PROVIDER.id
          Offer.create(offer_attributes)
        end
      end
    else
    end

  end

  # current_page = bot.page.parser.css(matchers[:current_page]).first.text.to_i
  # offers = bot.page.parser.css(matchers[:offers])




  # offers.each do |offer|
  #   biglion_id = offer.attr :id
  #   url = offer.css('.actionsItemHeadding a').first.attr :href
  #   image_url = offer.css('.photo a img').first.attr :src

  #   bot.get url



  #   # title = offer.css('.actionsItemHeadding a').text
  #   # price = offer.css('.price span').first.children.first.text.to_i
  # end


end
