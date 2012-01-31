# encoding: UTF-8

require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

require File.expand_path('../../lib/mixins/kupongid_tools', __FILE__)
include KupongidTools

#require 'tor-privoxy'

#@proxy = TorPrivoxy::Switcher.new '127.0.0.1', '', {8118 => 9050}
@bot = Mechanize.new
#@bot.set_proxy(@proxy.host, @proxy.port)

#puts @bot.get('http://ifconfig.me/ip').body

@log = Logger.new("#{$rails_root}/parsers/logs/kupongid.log")
@url = 'http://www.kupongid.ru'

@bot.get(@url)
@log.debug("Starting kupongid parser .. #{Time.now}")

cities = KupongidTools.cities # Cities mapping
saved = 0

cities.keys.each do |city|

  @log.info("Processing city #{city.name}")

  existing_offers = KupongidTools.existing_offers(city)
  saved_offers = []

  @bot.get( @url + '/' + cities[city] )

  # Pagination
  pagination_url = cities[city] + '?kuponmap=1&deal_groupID=0&select=select_all&offset=0'
  current_page, offset, offers_per_page, total_count = 1, 0, 20, @bot.page.parser.css('.total').first.text.to_i
  pages_count = (total_count % offers_per_page == 0) ? total_count/offers_per_page : total_count/offers_per_page + 1

  pages_count.times do
    offset = current_page == 1 ? 0 : current_page * offers_per_page
    @bot.get cities[city] + '?kuponmap=1&deal_groupID=0&select=select_all&offset=' + offset.to_s rescue binding.pry
    current_page += 1

    offer_patterns = @bot.page.parser.css('div.coupon')

    @log.info "Processing page #{current_page}"

    offer_patterns.each do |pattern|
      address = pattern.css('.location noindex').text.split('|')
      kupongid_provider_id = pattern.css('.source a').first['href'].gsub(/\D/, '').to_i
      url = pattern.css('.description h2 a.local').first['href']
      provided_id = url.gsub(/\D/, '')
      raw_description = pattern.css('.coupon-popup-tab').first

      raw_description.css('a').each do |a|
        if a['href'] =~ /kupongid/
          a.remove
        else
          a['target'] = 'blank'
          a['rel'] = 'nofollow'
        end
      end


      if existing_offers.include?(provided_id) || saved_offers.include?(provided_id)
        existing_offers.delete( provided_id )
        @log.info("Skipping existing offer #{provided_id}")
        next
      end

      if KupongidTools::AVAILABLE_PROVIDERS.include?(kupongid_provider_id)
        @log.info("Available provider: #{url}, skipping")
        next
      elsif not KupongidTools::PROVIDERS.keys.include?(kupongid_provider_id)
        @log.info("Unknown provider #{kupongid_provider_id} : #{url}")
        next
      end

      provider_url = begin
                       out_page = @bot.get(pattern.css(".buy").first['href'])
                       if out_page.uri.to_s =~ /kupongid/
                         out_page.links.last.href.gsub /\?.*/, ''
                       else
                         out_page.uri.to_s.gsub /\?.*/, ''
                       end
                     rescue Exception => e
                       nil
                     end

      offer = {
        url: provider_url,
        title: pattern.css('.description h2 a.local').text,
        provided_id: url.gsub(/\D/, ''),
        image: open( pattern.css('.image img').first['src'].gsub('_small', '') ),
        description: raw_description.css('p').count == 1 ? raw_description.text.gsub(/\n|\t|\r\n/, '') : raw_description.css('p')[1].text.gsub(/\n|\t|\r\n/, ''),
        ends_at: pattern.css('.time').text =~ /\dд/ ? pattern.css('.time').text.gsub(/д.*/, '').to_i.days.from_now : nil,
        subway: pattern.css('.location noindex b').text,
        address: address.count > 0 ? address[1].gsub(/Захотели купить.*/, '').strip : nil,
        price: pattern.css('.price-and-time strong').text.to_i,
        cost: pattern.css('.price-and-time .bold1').text.to_i,
        discount: pattern.css('.discount').text.to_i,
        provider_id: Provider.find_by_name(KupongidTools::PROVIDERS[kupongid_provider_id]).id,
        city_id: city.id,
        country_id: city.country_id,
        from_kupongid: true
      }

      model = Offer.new( offer )
      binding.pry
      if model.valid?
        @log.info("Saving offer #{model.provided_id}")
        city_clone = city.clone
        city_clone.offers << model
        saved += 1
        saved_offers << model.provided_id
      end
    end
  end

  @log.info("Finished processing #{city.name} ( #{Time.now} ). Saved #{saved_offers.count} new offers")

end

existing_offers.each do |expired_offer|
  @log.info "Removing expired offer #{expired_offer}"
  Offer.where(from_kupongid: true, provided_id: expired_offer).destroy
end

@log.info("Finished kupongid parser. Total #{saved} offers added, #{existing_offers.count} expired offers were removed")
