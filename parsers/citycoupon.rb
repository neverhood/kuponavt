# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

@url = 'http://citycoupon.ru/category/all'
@prefix = 'http://citycoupon.ru'
@bot = Mechanize.new
@provider = PROVIDER = Provider.where(:name => 'citycoupon').first
@log = Logger.new(File.expand_path('../logs/citycoupon.log', __FILE__))

cities = ["Москва"]

saved_offers = []
saved = 0

@log.info("Starting citycoupon parser: #{Time.now} ... ")

cities.each do |city|

  city = City.find_by_russian_name(city)
  @existing_offers = city.offers.where(provider_id: @provider.id).map(&:provided_id)

  @bot.get(@url+ '?city=' + city.russian_name)
  binding.pry unless city.name == 'moskva'
  offers = []

  (@bot.page.parser.css('.bannerbox a').map { |a| a['href'] } - [nil]).uniq.each do |link|
    offers << { url: @prefix + link, provided_id: link.gsub(/.*\//, '') }
  end

  @log.info("Processing #{city.name}")

  offers.each do |offer|

    if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
      @log.info("Skipping existing offer: #{offer[:provided_id]}")
      @existing_offers.delete(offer[:provided_id])
      offer = nil
      next
    end

    if Offer.where(provided_id: offer[:provided_id], provider_id: @provider.id).any?
      existing_model = Offer.where(provided_id: offer[:provided_id], provider_id: @provider.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer[:url])
      @log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      existing_model = nil
      next
    end

    binding.pry if Offer.where(provider_id: @provider.id, title: 'lasfasfahusf').any?

    @bot.get offer[:url]
    contacts = @bot.page.parser.css('#condcontainer .rightcolumn ul').first

    offer[:city_id] = city.id
    offer[:country_id] = city.country_id
    offer[:provider_id] = @provider.id
    offer[:title] = @bot.page.parser.css('td.descrtext p').text
    offer[:discount] = @bot.page.parser.css('td.discount div').text.to_i
    offer[:cost] = @bot.page.parser.css('td.fullprice div').text.to_i
    offer[:price] = @bot.page.parser.css('#buyprice').text.to_i
    image_url = @prefix + $1 if @bot.page.parser.css('#deal-image').first['style'] =~ /\((.*)\)/
    offer[:image] = open( image_url ) if image_url
    offer[:address] = contacts.css('li').first.text.gsub(/адрес: /i, '')
    offer[:subway] = contacts.css('li')[1].text.gsub(/М\./i, '').strip
    raw_description = @bot.page.parser.css('#condcontainer td.leftcolumn')
    raw_description.css('img').each do |img|
      unless img['src'] =~ /citycoupon\.ru/
        img['src'] = @prefix + img['src']
      end
    end
    offer[:description] = description('citycoupon.ru', raw_description).to_html

    model = Offer.new( offer )

    if model.valid?
      city_clone = city.clone # city includes offers and raises as fuck ( memory )
      city_clone.offers << model
      @log.info("Saving offer: #{model.provided_id}")
      saved_offers << model.provided_id
      saved += 1
      city_clone = nil # Not sure if it's needed
    else
      @log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
    end
  end

  @existing_offers.each do |expired_offer|
    @log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end

end

@log.info "Finished parsing citycoupon. Total of #{saved} new offers were added"
