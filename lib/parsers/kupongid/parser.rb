# coding: utf-8
#require 'mechanize'
#require 'pry'
#require 'active_record'

#rails_root = (ENV['RAILS_ROOT'] || File.expand_path('../../../', __FILE__))
#$LOAD_PATH << rails_root

#db_config = YAML::load( File.open('config/database.yml') )
#ActiveRecord::Base.establish_connection(db_config['development'])

require File.expand_path('../../init.rb', __FILE__)
require 'app/parsers/parser'
require 'app/parsers/kupongid/kupongid_parser'
require 'app/models/kupongid'
require 'app/models/category'

#$agent = Mechanize.new

#$agent.post(Kupongid::DETAILS[:address], Kupongid::DETAILS[:authentication]) # Authenticate


@engine = KupongidParser
@engine.authenticate!

#$agent.post( @engine.authentication_details[:address], @engine.authentication_details[:params] )

all_offers_link = $agent.page.link_with(:text => 'все')

@total = $1.to_i if $agent.page.parser.xpath('//div[@class="tags clear"]/p/a[@class="on"]').text =~ /(\d+)/
@all_offers = -> { $agent.page.parser.xpath('//noindex/div[contains(@class, "deal")]') }
@offer_links = []
@existent_offer_ids = Kupongid.select(:kupongid_id).map(&:kupongid_id)


all_offers_link.click

@all_offers.call.each do |offer_box|
  link = offer_box.css('a[href*="/deal/"]').first['href']
  offer_id = $1.to_i if link =~ /(\d+)/
  @offer_links << link unless @existent_offer_ids.include?(offer_id)
end


@offers = []
@offer_links.each do |offer_link|
  begin
    $agent.get offer_link

   offer = {}
   offer[:url] = $agent.page.uri.to_s
   offer[:kupongid_id] = $agent.page.uri.to_s.match(/\d+/).to_s.to_i
   offer[:title] = $agent.page.parser.css('h1').text.strip
   offer[:discount] = $agent.page.parser.css('div.deal div.percent').text.to_i
   offer[:image_url] = $agent.page.parser.css('div.deal img.image').first['src']
   offer[:cost], offer[:price] = $agent.page.parser.css('div.deal li.discount span').text.scan(/\d+/).map(&:to_i)
   offer[:ends_at] = ($agent.page.parser.css('div.deal li.countdown').first['data-time-left'].to_i/3600 + 3).hours.from_now.to_date
   offer[:description] = $1 if $agent.page.parser.xpath("//div[@id='deal#{offer[:kupongid_id]}']/div[4]").text.strip =~ /(.*)\n/m
   offer[:subway], offer[:address] = $agent.page.parser.css("div.deal .address").text.strip.gsub(/\s*-\s*показать/, '').split('|').map(&:strip)
   offer[:provider] = $agent.page.parser.css("div.deal a[href*='deal/out']").text.gsub(/Купить на /, '')

   offer[:city_id], offer[:country_id] = 1, 1

   if offer[:price].nil?
     offer[:price] = offer[:cost]
     offer[:cost] = nil
   end

   offer[:subway] = nil if offer[:subway] && offer[:subway].gsub(/[ ,-\\"'`]*/, '').empty?

   category_name = $agent.page.parser.xpath('//div[contains(@class,"deal")]/div/div/noindex/p/a[1]').last.text
   category_name = 'Отели, путешествия' if category_name == 'Авиабилеты'

   category = Category.where(:name => category_name).first

   offer[:category_id] = category.id if category

   binding.pry if category.nil?

  rescue Exception
  end

  begin
    $agent.get @engine.authentication_details[:address] + "deal/out/#{offer[:kupongid_id]}"
    offer[:provider_url] = $agent.page.links.last.href
  rescue Exception
  end
  unless offer.nil?
    puts 'Saving offer with kupongid_id ' + offer[:kupongid_id].to_s
    Kupongid.create( offer )
  end

end
