# coding: utf-8
require 'mechanize'
require 'pry'
require 'active_record'

rails_root = (ENV['RAILS_ROOT'] || File.expand_path('../../../', __FILE__))
$LOAD_PATH << rails_root

db_config = YAML::load( File.open('config/database.yml') )
ActiveRecord::Base.establish_connection(db_config['development'])


require 'app/models/kupongid'
require 'app/models/site'

agent = Mechanize.new

agent.post(Kupongid::DETAILS[:address], Kupongid::DETAILS[:authentication]) # Authenticate

all_offers_link = agent.page.link_with(:text => 'все')

@total = $1.to_i if agent.page.parser.xpath('//div[@class="tags clear"]/p/a[@class="on"]').text =~ /(\d+)/
@all_offers = -> { agent.page.parser.xpath('//noindex/div[contains(@class, "deal")]') }
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
  agent.get offer_link

  offer = {}
  offer[:url] = agent.page.uri.to_s
  offer[:kupongid_id] = agent.page.uri.to_s.match(/\d+/).to_s.to_i
  offer[:title] = agent.page.parser.css('h1').text.strip
  offer[:discount] = agent.page.parser.css('div.deal div.percent').text.to_i
  offer[:image_url] = agent.page.parser.css('div.deal img.image').first['src']
  offer[:price], offer[:price_with_discount] = agent.page.parser.css('div.deal li.discount span').text.scan(/\d+/).map(&:to_i)
  offer[:ends_at] = (agent.page.parser.css('div.deal li.countdown').first['data-time-left'].to_i/3600 + 3).hours.from_now.to_date
  offer[:description] = $1 if agent.page.parser.xpath("//div[@id='deal#{offer[:kupongid_id]}']/div[4]").text.strip =~ /(.*)\n/m
  offer[:subway], offer[:address] = agent.page.parser.css("div.deal .address").text.strip.gsub(/\s*-\s*показать/, '').split('|').map(&:strip)
  offer[:provider] = agent.page.parser.css("div.deal a[href*='deal/out']").text.gsub(/Купить на /, '')

  offer[:subway] = nil if offer[:subway].gsub(/\W/, '').empty?

  binding.pry

  agent.get Kupongid::DETAILS[:address] + "deal/out/#{offer[:kupongid_id]}"

  offer[:provider_url] = agent.page.parser.css('b').text
  binding.pry
  Kupongid.create( offer )

end
