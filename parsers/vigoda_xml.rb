# encoding: UTF-8

require File.expand_path('../../lib/mixins/parser', __FILE__)
include Parser

PROVIDER = Provider.find_by_name('vigoda')
@log = Logger.new(File.expand_path('../logs/vigoda_xml.log', __FILE__))
xml_offers = Nokogiri::XML( open 'http://vigoda.ru/api/xml' ).xpath('//offer')

cities = ["Москва", "Санкт-Петербург", "Альметьевск", "Архангельск", "Астрахань", "Барнаул", "Брянск", "Владивосток",
          "Волгоград", "Волжский", "Вологда", "Воронеж", "Екатеринбург", "Иваново", "Ижевск", "Иркутск", "Йошкар-Ола",
          "Казань", "Калининград", "Калуга", "Кемерово", "Киров", "Кострома", "Краснодар", "Красноярск",
          "Курск", "Липецк", "Магнитогорск", "Мурманск", "Набережные Челны", "Нижнекамск", "Нижний Новгород",
          "Новокузнецк", "Новосибирск", "Норильск", "Омск", "Орел", "Пенза", "Пермь", "Петрозаводск", "Петропавловск Камчатский",
          "Псков", "Ростов-на-Дону", "Рязань", "Салехард", "Самара", "Саратов", "Смоленск", "Сочи", "Сургут", "Сыктывкар", "Тверь",
          "Тольятти", "Томск", "Тула", "Тюмень", "Улан-Удэ", "Ульяновск", "Уфа", "Хабаровск", "Ханты-Мансийск", "Чебоксары",
          "Челябинск", "Череповец", "Чита", "Южно-Сахалинск", "Якутск", "Ярославль", "Киев", "Днепропетровск", "Донецк",
          "Запорожье", "Ивано-Франковск", "Луганск", "Львов", "Николаев", "Одесса", "Полтава", "Севастополь", "Тернополь",
          "Харьков", "Херсон", "Чернигов"]

@log.info("Starting vigoda xml parser: #{Time.now}")

saved = 0

cities.each do |city|
  city = City.find_by_russian_name(city)

  @log.info("Processing #{city.name}")

  saved_offers = []
  existing_offers = city.offers.where(provider_id: PROVIDER.id).map(&:provided_id)
  city_offers = []
  xml_offers.map do |offer|
    if offer.xpath('region').text == city.russian_name
      city_offers << offer
      nil
    else
      offer
    end
  end

  @log.info("Found #{city_offers.count} offers")

  city_offers.each do |offer|
    provided_id = offer.xpath('id').text
    title = offer.xpath('name').text

    if existing_offers.include?(provided_id) || saved_offers.include?(provided_id)
      @log.info("Skipping existing offer: #{offer.xpath('id').text}")
      existing_offers.delete(provided_id)
      next
    end

    if Offer.where(title: title, provider_id: PROVIDER.id).any?
      existing_model = Offer.where(title: title, provider_id: PROVIDER.id).first
      CitiesOffers.create(city_id: city.id, offer_id: existing_model.id, url: offer.xpath('url').text)
      @log.info("Added existing offer #{existing_model.provided_id} to city #{city.name}")
      next
    end

    offer_attributes = {
      title: offer.xpath('name').text,
      provider_id: PROVIDER.id,
      provided_id: offer.xpath('id').text,
      url: offer.xpath('url').text,
      description: offer.xpath('description').text.gsub("\n", "<br />"),
      ends_at: Time.parse(offer.xpath('endsell').text.gsub('T',' ')) + 1,
      image: open( offer.xpath('picture').text ),
      price: offer.xpath('pricecoupon').text.to_i,
      cost: (offer.xpath('price').text.to_i),
      discount: offer.xpath('discount').text.to_i,
      address: offer.xpath('supplier/addresses/address/name').map(&:text).map(&:strip).join("||"),
      coordinates: offer.xpath('supplier/addresses/address/coordinates').map(&:text).join("||"),
      country_id: city.country.id,
      city_id: city.id
    }
    offer_attributes[:price] = offer.xpath('discountprice').text.to_i if offer_attributes[:price] == 0
    offer_attributes[:coordinates] = nil if offer_attributes[:coordinates].blank?
    offer_attributes[:address] = nil if offer_attributes[:address].blank?

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

@log.info("Finished vigoda xml parser. #{saved} offers added. #{Time.now}")
