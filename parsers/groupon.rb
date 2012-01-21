# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

@url = 'http://groupon.ru'
@bot = Mechanize.new
@provider = PROVIDER = Provider.where(:name => 'groupon').first
@existing_offers = Offer.where(provider_id: @provider.id).map(&:provided_id)
@log = Logger.new(File.expand_path('../logs/groupon.log', __FILE__))

city_names = ["Москва", "Санкт-Петербург", "Архангельск", "Астрахань", "Барнаул", "Белгород", "Брянск",
          "Великий Новгород", "Владивосток", "Владимир", "Волгоград", "Воронеж", "Екатеринбург", "Иваново",
          "Ижевск", "Иркутск", "Казань", "Калининград", "Калуга", "Кемерово", "Киров", "Краснодар", "Красноярск",
          "Курган", "Курск", "Липецк", "Магнитогорск", "Махачкала", "Мурманск", "Набережные Челны", "Нижневартовск",
          "Нижний Новгород", "Нижний Тагил", "Новокузнецк", "Новосибирск", "Омск", "Оренбург", "Пенза", "Пермь",
          "Петрозаводск", "Ростов-на-Дону", "Рязань", "Самара", "Саратов", "Смоленск", "Сочи", "Ставрополь",
          "Стерлитамак", "Тамбов", "Тверь", "Тольятти", "Томск", "Тула", "Тюмень", "Улан-Удэ", "Ульяновск",
          "Уфа", "Хабаровск", "Чебоксары", "Челябинск", "Ярославль"
]

city_urls = ["http://groupon.ru/user/change_city?city=1", "http://groupon.ru/user/change_city?city=2",
             "http://groupon.ru/user/change_city?city=70", "http://groupon.ru/user/change_city?city=63",
             "http://groupon.ru/user/change_city?city=26", "http://groupon.ru/user/change_city?city=46",
             "http://groupon.ru/user/change_city?city=76", "http://groupon.ru/user/change_city?city=54",
             "http://groupon.ru/user/change_city?city=53", "http://groupon.ru/user/change_city?city=71",
             "http://groupon.ru/user/change_city?city=15", "http://groupon.ru/user/change_city?city=21",
             "http://groupon.ru/user/change_city?city=5", "http://groupon.ru/user/change_city?city=68",
             "http://groupon.ru/user/change_city?city=61", "http://groupon.ru/user/change_city?city=24",
             "http://groupon.ru/user/change_city?city=6", "http://groupon.ru/user/change_city?city=67",
             "http://groupon.ru/user/change_city?city=72", "http://groupon.ru/user/change_city?city=31",
             "http://groupon.ru/user/change_city?city=66", "http://groupon.ru/user/change_city?city=22",
             "http://groupon.ru/user/change_city?city=25", "http://groupon.ru/user/change_city?city=80",
             "http://groupon.ru/user/change_city?city=84", "http://groupon.ru/user/change_city?city=50",
             "http://groupon.ru/user/change_city?city=45", "http://groupon.ru/user/change_city?city=78",
             "http://groupon.ru/user/change_city?city=75", "http://groupon.ru/user/change_city?city=65",
             "http://groupon.ru/user/change_city?city=81", "http://groupon.ru/user/change_city?city=4",
             "http://groupon.ru/user/change_city?city=83", "http://groupon.ru/user/change_city?city=32",
             "http://groupon.ru/user/change_city?city=3", "http://groupon.ru/user/change_city?city=8",
             "http://groupon.ru/user/change_city?city=33", "http://groupon.ru/user/change_city?city=64",
             "http://groupon.ru/user/change_city?city=13", "http://groupon.ru/user/change_city?city=47",
             "http://groupon.ru/user/change_city?city=19", "http://groupon.ru/user/change_city?city=62",
             "http://groupon.ru/user/change_city?city=7", "http://groupon.ru/user/change_city?city=20",
             "http://groupon.ru/user/change_city?city=77", "http://groupon.ru/user/change_city?city=74",
             "http://groupon.ru/user/change_city?city=49", "http://groupon.ru/user/change_city?city=51",
             "http://groupon.ru/user/change_city?city=82", "http://groupon.ru/user/change_city?city=69",
             "http://groupon.ru/user/change_city?city=60", "http://groupon.ru/user/change_city?city=59",
             "http://groupon.ru/user/change_city?city=48", "http://groupon.ru/user/change_city?city=23",
             "http://groupon.ru/user/change_city?city=79", "http://groupon.ru/user/change_city?city=34",
             "http://groupon.ru/user/change_city?city=16", "http://groupon.ru/user/change_city?city=52",
             "http://groupon.ru/user/change_city?city=73", "http://groupon.ru/user/change_city?city=9",
             "http://groupon.ru/user/change_city?city=35"
]

cities = {}
city_names.each { |city_name| cities[city_name] = city_urls[city_names.index(city_name)] }

saved = 0

@log.info("Starting groupon parser: #{Time.now} ... ")

cities.keys.each do |city|


  city = City.find_by_russian_name(city)
  offers = []
  saved_offers = []
  @existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)

  @log.info("Started processing #{city.name}: #{Time.now}")

  @bot.get cities[city.russian_name]

  @bot.page.parser.css('div[role="offer"] h2 a').each do |a|
    offers << { url: @url + a['href'], provided_id: a['href'].gsub(/.*\//, '') }
  end


  offers.each do |offer|

    if @existing_offers.include?(offer[:provided_id]) || saved_offers.include?(offer[:provided_id])
      @log.info("Skipping existing offer: #{offer[:provided_id]}")
      @existing_offers.delete(offer[:provided_id])
      offer = nil
      next
    end

    if Offer.where(:provided_id => offer[:provided_id], :provider_id => PROVIDER.id).any?
      existing_model = Offer.where(:provided_id => offer[:provided_id], :provider_id => PROVIDER.id).first
      CitiesOffers.create(offer_id: existing_model.id, city_id: city.id, url: offer[:url])
      existing_model = nil
      @log.info("Added existing offer #{offer[:provided_id]} to #{city.name}")
      next
    end

    @bot.get offer[:url]

    pattern = @bot.page.parser.css('#offer')
    info = pattern.css('.info')
    location = @bot.page.parser.css('.location').first
    subways, addresses = [], []

    next unless info.css('strong[data-timestamp]').first


    offer[:provider_id] = @provider.id
    offer[:title] = pattern.css('h1').first.text
    offer[:price] = info.css('.price').text.gsub(/\D/, '').to_i
    offer[:cost] = info.css('table td').first.text.gsub(/\D/, '').to_i
    offer[:discount] = info.css('table td')[1].text.gsub(/\D/, '').to_i
    offer[:ends_at] = Time.at(info.css('strong[data-timestamp]').first['data-timestamp'].to_i + (120*60))
    offer[:image] = open( @bot.page.parser.css('.slideshow img').first['src'] )
    offer[:description] = description('groupon.ru', @bot.page.parser.css('.description').first).to_html.gsub(/\n|\r\n/, "<br /><br />")
    offer[:city_id] = city.id
    offer[:country_id] = city.country_id
    offer[:subway] = location.css('.metro').map { |m| m.text.strip }.join("||") if location
    offer[:address] = location.css('.address').map { |a| a.text.strip }.join("||") if location

    offer[:subway] = nil if offer[:subway].blank?
    offer[:address] = nil if offer[:address].blank?

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
    @bot = Mechanize.new
  end

  @log.info("finished processing #{city.name}")
  @existing_offers.each do |expired_offer|
    @log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end

end

@log.info "Finished parsing groupon. Total of #{saved} new offers were added"
