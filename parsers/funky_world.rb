# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

require 'chronic'

@url = 'http://funkyworld.ru'
@bot = Mechanize.new
@provider = PROVIDER = Provider.where(:name => 'funkyworld').first
@existing_offers = Offer.where(provider_id: @provider.id).map(&:provided_id)
@log = Logger.new(File.expand_path('../logs/funkyworld.log', __FILE__))


city = City.find_by_name('moskva')
offers = []
saved_offers = []
saved = 0

@log.info("Starting funkyworld parser: #{Time.now} ... ")

@bot.get(@url)

@bot.page.parser.css('.item .image').map do |a|
  offers << { url: @url + a['href'], provided_id: a['href'].gsub(/\/moscow\/|\/$/, '') }
end

form = @bot.page.form_with(action: /sign_in/) { |form|
  form['login'] = 'kuponavt.co@gmail.com'
  form['passwd'] = 'k2o32k2o32'
  form['password'] = 'k2o32k2o32'
}.submit

offers.each do |offer|

  if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
    @log.info("Skipping existing offer: #{offer[:provided_id]}")
    @existing_offers.delete(offer[:provided_id])
    offer = nil
    next
  end

  @bot.get offer[:url]
  pattern = @bot.page.parser.css('.catalog_item')

  offer[:provider_id] = @provider.id
  offer[:title] = pattern.css('h1').first.text
  offer[:price] = pattern.css('.cost').first.text.gsub(/\D/, '').to_i
  offer[:cost] = $1.to_i if offer[:title] =~ /вместо\s*(\d+)/
  offer[:cost] = 0 if offer[:cost].nil?

  offer[:discount] = $1.to_i if pattern.css('.info .titled').text =~ /(\d+)%/

  offer[:ends_at] = Chronic.parse $1 if pattern.css('.timer script').text =~ /.*,"(.*)(AM|PM)/
  image_url = (@url + $1) if pattern.css('.item_table .l div.image').first['style'] =~ /\((.*)\)/
  offer[:image] = open(image_url) if image_url
  raw_description = pattern.css('.item_desc_table td.l .block_text, .item_desc_table td.l .block_image')
  desc = description('funkyworld.ru', raw_description)
  desc.css('img').each do |img|
    img['src'] = @url + img['src']
  end

  offer[:description] = desc.to_html.encode('utf-8')
  offer[:city_id] = city.id
  offer[:country_id] = city.country_id
  offer[:address] = $1 if pattern.css('.item_desc_table td.l div.right p').text =~ /адрес.*:\s*(.*)/i
  offer[:address] = offer[:address].strip if offer[:address]

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


@log.info "Finished parsing fun2mass. Total of #{saved} new offers were added"
