module KupongidTools

  # 1 = biglion, 10 = vigoda, 202 = discounter, 12 = weclever, 3 = kupikupon, 231 = yakupon, 15 - kupibonus, 8 - fun2mass, 271 - discounti, 113 - myfant, 43 - alkupone, 17 - skidkaest, 118 - lisalisa, 11 - cityradar, 14 - billkill, 44 - discount-today, 230 - qpon, 193 - ladykupon, 243 - carpot, 55 - boombate, 51 - hipclub, 28 - sellberry, 106 - funkyworld, 171 - newnotion, 186 - kuponya, 255 - ostrovok, 34 - brandel, 58 - ckidki, 93 - vkusoflife, 192 - saleforman, 208 - planet-eds, 22 - dailysmiles, 160 - maxbery, 126 - citycoupon, 175 - mafam, 68 - bestkupon, 73 - bonkupon, 9 - joybuy, 16 - megakupon, 184 - obval, 98 - kingcoupon, 153 - darget, 249 - halyavaproject, 217 - lotbest, 40 - skuponom, 85 - gorodinfo, 2 - groupon, 220 - salesforyou, 191 - megackidki, 83 - kidskupon, 127 - kupon, 226 - hotbaklazhan, 187 - diprice, 101 - slonkupon, 222 - ctwoman, 180 - saynobody, 144 - mydarin, 224 - azbuka-skidok, 71 - autokupon, 120 - wildprice, 25 - glavskidka, 163 - couponhouse, 151 - 5ine, 212 - skidkumne, 56 - expresskupon, 122 - etook, 233 - shopogoliq, 195 - bonimani, 135 - bank-skidki, 154 - viptalon, 13 - izumgoroda, 203 - polzagroup, 174 - vacaloca, 155 - kupontravel, 7 - bigbuzzy, 74 - vipkupon, 229 - skidogolik, 182 - biglift, 228 - restoran-city, 263 - appiny, 273 - intercoupon, 63 - skidman, 246 - kuponid, 259 - darrom, 260 - dealtimes, 253 - pluskupon, 238 - city-kupon, 266 - pro-cent, 252 - dringo, 242 - bankskidok, 138 - kupiotpusk, 272 - sugarsales, 265 - bontalon, 225 - bigsaving, 119 - skidka50, 82 - bonusprice
  AVAILABLE_PROVIDERS = [ 1, 10 ]

  providers = { 10 => 'biglion'}

  def self.authenticate! bot, login_params
    bot.get('http://www.kupongid.ru/')

    bot.page.form_with(id: 'login_form') { |form|
      form.login = login_params[:login]
      form.password = login_params[:password]
    }.submit
    bot
  end

  def self.cities
    Hash[[
      [ City.find_by_name('moskva'), 'moskva' ],
      [ City.find_by_name('kiev'), 'kiev' ]
    ]]
  end

  def self.existing_offers(city_id)
    ::Offer.where(city_id: city_id, from_kupongid: true).map(&:provided_id)
  end

  class Pattern

    attr_accessor :source, :provider_id, :offer_id, :url

    def initialize(pattern)
      @source = pattern
      @provider_id = pattern.css('.negotiated a').first['href'].scan(/\d+/).first.to_i
      @offer_id = pattern.css('div').first['id'].gsub('deal', '')
      @url = pattern.css('.h2 a').first['href']
    end

    def should_follow?
      #not KupongidTools::AVAILABLE_PROVIDERS.include?(offer_id)
      if KupongidTools::AVAILABLE_PROVIDERS.include?(offer_id)
        puts 'EXISTING PROVIDER'
        false
      else
        puts 'NOT EXISTING PROVIDER'
        true
      end
    end

  end

  class PagePattern
  end

end
