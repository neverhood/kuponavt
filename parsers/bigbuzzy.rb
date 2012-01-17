# encoding: UTF-8
require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

PROVIDER = Provider.find_by_name('bigbuzzy')
@log = Logger.new(File.expand_path('../logs/bigbuzzy.log', __FILE__))

xml_offers = []
xml = Nokogiri::XML( open('http://bigbuzzy.ru/xml/') )

xml_offers << xml.xpath('//offer').to_a
xml_current_page = 1
xml_total_pages = xml.xpath('//navigation/total_pages').text.to_i

(xml_total_pages - 1).times do
  xml = Nokogiri::XML( open( xml.xpath('//navigation/next_page').text ) )
  xml_offers << xml.xpath('//offer').to_a
end

xml_offers = xml_offers.flatten


cities = ["Москва", "Санкт-Петербург", "Нижний Новгород", "Казань", "Уфа", "Саратов", "Смоленск", "Ставрополь", "Кемерово",
          "Екатеринбург", "Архангельск", "Астрахань", "Барнаул", "Белгород", "Брянск", "Владивосток", "Владикавказ",
          "Владимир", "Волгоград", "Волжский", "Вологда", "Воронеж", "Иваново", "Ижевск", "Иркутск", "Калининград",
          "Калуга", "Киров", "Комсомольск-на-Амуре", "Кострома", "Краснодар", "Красноярск", "Курган", "Курск", "Липецк",
          "Магнитогорск", "Махачкала", "Мурманск", "Набережные Челны", "Нальчик", "Нижневартовск", "Нижний Тагил",
          "Новокузнецк", "Новосибирск", "Омск", "Орёл", "Оренбург", "Пенза", "Пермь", "Петрозаводск", "Ростов-на-Дону",
          "Рязань", "Самара", "Саранск", "Сочи", "Стерлитамак", "Сургут", "Таганрог", "Тамбов", "Тверь", "Тольятти", "Томск",
          "Тула", "Тюмень", "Улан-Удэ", "Ульяновск", "Хабаровск", "Чебоксары", "Челябинск", "Череповец", "Чита", "Якутск", "Ярославль"]

@log.info("Starting bigbuzzy parser: #{Time.now}")

saved = 0

cities.each do |city|
  city = City.find_by_russian_name(city)

  @log.info("Processing #{city.name}")

  saved_offers = []
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
  city_offers = xml_offers.select { |offer| offer.xpath('region').text == city.russian_name }

  @log.info("Found #{city_offers.count} offers")

  city_offers.each do |offer|
    provided_id = offer.xpath('id').text

    if existing_offers.include?(provided_id) || saved_offers.include?(provided_id)
      @log.info("Skipping existing offer: #{offer.xpath('id').text}")
      existing_offers.delete(provided_id)
      next
    end

    if Offer.where(title: offer.xpath('name').text, provider_id: PROVIDER.id).any?
      existing_model = Offer.where(title: offer.xpath('name').text, provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer.xpath('url').text)
      @log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      next
    end

    offer_attributes = {
      title: offer.xpath('name').text,
      provider_id: PROVIDER.id,
      provided_id: offer.xpath('id').text,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text,
      ends_at: Time.parse(offer.xpath('endsell').text.gsub('T',' ')) + 1,
      image: open( offer.xpath('picture').text ),
      price: offer.xpath('pricecoupon').text.to_i,
      cost: (offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').map(&:text).map(&:strip).join('||'),
      coordinates: offer.xpath('supplier/addresses/address/coordinates').map(&:text).join('||'),
      city_id: city.id,
      country_id: city.country_id
    }
    offer_attributes[:price] = offer.xpath('discountprice').text.to_i if offer_attributes[:price] == 0

    model = Offer.new( offer_attributes )
    if model.valid?
      @log.info("Saving offer #{provided_id}")
      city.offers << model
      saved_offers << model.provided_id
      saved += 1
    else
      @log.error("Can't save invalid offer: #{model.provided_id}. \n #{model.errors.full_messages.join(',')}")
      binding.pry
    end

  end

  existing_offers.each do |expired_offer|
    @log.info("Removing expired offer #{expired_offer}")
    Offer.where(provider_id: PROVIDER.id, provided_id: expired_offer).first.destroy
  end

  @log.info("Finished processing #{city.name} ( #{Time.now} ). Saved #{saved_offers.count} new offers")
end

@log.info("Finished bigbuzzy parser. #{saved} offers added. #{Time.now}")
