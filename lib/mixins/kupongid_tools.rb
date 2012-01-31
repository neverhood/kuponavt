# encoding: UTF-8
module KupongidTools

  # 1 - biglion, 10 - vigoda, 202 - discounter, 12 - weclever, 3 - kupikupon, 231 - yakupon, 15 - kupibonus, 8 - fun2mass, 271 - discounti, 113 - myfant, 43 - alkupone, 17 - skidkaest, 118 - lisalisa, 11 - cityradar, 14 - billkill, 44 - discount-today, 230 - qpon, 193 - ladykupon, 243 - carpot, 55 - boombate, 51 - hipclub, 28 - sellberry, 106 - funkyworld, 171 - newnotion, 186 - kuponya, 255 - ostrovok, 34 - brandel, 58 - ckidki, 93 - vkusoflife, 192 - saleforman, 208 - planet-eds, 22 - dailysmiles, 160 - maxbery, 126 - citycoupon, 175 - mafam, 68 - bestkupon, 73 - bonkupon, 9 - joybuy, 16 - megakupon, 184 - obval, 98 - kingcoupon, 153 - darget, 249 - halyavaproject, 217 - lotbest, 40 - skuponom, 85 - gorodinfo, 2 - groupon, 220 - salesforyou, 191 - megackidki, 83 - kidskupon, 127 - kupon, 226 - hotbaklazhan, 187 - diprice, 101 - slonkupon, 222 - ctwoman, 180 - saynobody, 144 - mydarin, 224 - azbuka-skidok, 71 - autokupon, 120 - wildprice, 25 - glavskidka, 163 - couponhouse, 151 - 5ine, 212 - skidkumne, 56 - expresskupon, 122 - etook, 233 - shopogoliq, 195 - bonimani, 135 - bank-skidki, 154 - viptalon, 13 - izumgoroda, 203 - polzagroup, 174 - vacaloca, 155 - kupontravel, 7 - bigbuzzy, 74 - vipkupon, 229 - skidogolik, 182 - biglift, 228 - restoran-city, 263 - appiny, 273 - intercoupon, 63 - skidman, 246 - kuponid, 259 - darrom, 260 - dealtimes, 253 - pluskupon, 238 - city-kupon, 266 - pro-cent, 252 - dringo, 242 - bankskidok, 138 - kupiotpusk, 272 - sugarsales, 265 - bontalon, 225 - bigsaving, 119 - skidka50, 82 - bonusprice
  AVAILABLE_PROVIDERS = [ 1, 10, 7, 14, 195, 34, 90, 17, 12, 55, 85, 118, 73, 8, 82, 44, 9, 113, 2, 106, 71, 126, 43, 11, 113, 208, 266, 193, 3, 202 ]
  PROVIDERS = {1=>"biglion", 10=>"vigoda", 165=>'planear', 205=>'myredcat', 165 => 'donkupone', 202=>"discounter", 12=>"weclever", 3=>"kupikupon", 231=>"yakupon", 15=>"kupibonus", 8=>"fun2mass", 271=>"discounti", 113=>"myfant", 43=>"alkupone", 17=>"skidkaest", 118=>"lisalisa", 11=>"cityradar", 14=>"billkill", 44=>"discount-today", 230=>"qpon", 193=>"ladykupon", 194=>'clubkupon', 243=>"carpot", 55=>"boombate", 51=>"hipclub", 28=>"sellberry", 106=>"funkyworld", 171=>"newnotion", 186=>"kuponya", 255=>"ostrovok", 34=>"brandel", 58=>"ckidki", 93=>"vkusoflife", 192=>"saleforman", 208=>"planet-eds", 22=>"dailysmiles", 160=>"maxbery", 126=>"citycoupon", 175=>"mafam", 68=>"bestkupon", 73=>"bonkupon", 9=>"joybuy", 16=>"megakupon", 184=>"obval", 98=>"kingcoupon", 153=>"darget", 249=>"halyavaproject", 217=>"lotbest", 40=>"skuponom", 85=>"gorodinfo", 2=>"groupon", 220=>"salesforyou", 191=>"megackidki", 83=>"kidskupon", 127=>"kupon", 226=>"hotbaklazhan", 187=>"diprice", 101=>"slonkupon", 222=>"ctwoman", 180=>"saynobody", 144=>"mydarin", 224=>"azbuka-skidok", 71=>"autokupon", 120=>"wildprice", 25=>"glavskidka", 163=>"couponhouse", 151=>"5ine", 212=>"skidkumne", 56=>"expresskupon", 122=>"etook", 233=>"shopogoliq", 195=>"bonimani", 135=>"bank-skidki", 154=>"viptalon", 13=>"izumgoroda", 203=>"polzagroup", 174=>"vacaloca", 155=>"kupontravel", 7=>"bigbuzzy", 74=>"vipkupon", 229=>"skidogolik", 182=>"biglift", 228=>"restoran-city", 263=>"appiny", 273=>"intercoupon", 63=>"skidman", 246=>"kuponid", 259=>"darrom", 260=>"dealtimes", 253=>"pluskupon", 238=>"city-kupon", 266=>"pro-cent", 252=>"dringo", 242=>"bankskidok", 138=>"kupiotpusk", 272=>"sugarsales", 265=>"bontalon", 225=>"bigsaving", 119=>"skidka50", 82=>"bonusprice"}

  providers = { 10 => 'biglion'}

  def self.authenticate! bot, login_params
    bot.get('http://www.kupongid.ru/')

    bot.page.form_with(id: 'login_form') { |form| form.login = login_params[:login]
      form.password = login_params[:password]
    }.submit
    bot
  end

  def self.cities
    Hash[[
      [ City.find_by_name('moskva'), 'moskva' ],
      [ City.find_by_name('sankt-peterburg'), 'sankt-peterburg' ],
      [ City.find_by_name('kiev'), 'kiev' ]
    ]]
  end

  def self.existing_offers(city)
    city.offers.where(from_kupongid: true).map(&:provided_id)
    #Offer.select(:provided_id).where(city_id: city_id, from_kupongid: true).map(&:provided_id)
  end

  class Pattern
    #require 'tor-privoxy'

    #@@proxy = TorPrivoxy::Switcher.new '127.0.0.1', '', {8118 => 9050}
    @@bot = Mechanize.new
    #@@bot.set_proxy(@@proxy.host, @@proxy.port)


    attr_accessor :source, :provider_id, :offer_id, :url, :image_file, :cached_attributes

    def initialize(pattern)
      @provider_id = pattern.css('.negotiated a').first['href'].scan(/\d+/).first.to_i
      @offer_id = pattern.css('div').first['id'].gsub('deal', '')
      @url = pattern.css('.h2 a').first['href']
      @source = nil
      @image_file = nil
    end

    def should_follow?
      if KupongidTools::AVAILABLE_PROVIDERS.include?(self.provider_id)
        false
      elsif not KupongidTools::PROVIDERS.keys.include?(self.provider_id)
        puts "UNKNOWN PROVIDER #{self.provider_id} : #{self.url}"
        false
      else
        true
      end
    end

    def attributes
      self.source = @@bot.get(self.url).
        parser.css('#content')

      attrs = {
        provider_id: Provider.find_by_name(PROVIDERS[self.provider_id]).id,
        from_kupongid: true,
        provided_id: self.offer_id,
        title: title,
        discount: discount,
        cost: cost,
        price: price,
        ends_at: ends_at,
        description: description,
        subway: subway,
        address: address,
        url: provider_url
      }
      if image
        cached_attributes = attrs.merge({image: image_file})
      else
        cached_attributes = attrs
      end
      @@bot = Mechanize.new
      #@@bot.set_proxy(@@proxy.host, @@proxy.port)
      cached_attributes
    end

    def title
      source.css('h1').first.text rescue nil
    end

    def discount
      source.css('.percent').first.text.to_i rescue nil
    end

    def cost
      source.css('.discount .bold1[style]').text.to_i rescue nil
    end

    def price
      source.css('.discount .bold1').last.text.to_i rescue nil
    end

    def ends_at
      (source.css('.countdown').first['data-time-left'].to_i/3600 + 2).hours.from_now.to_date rescue nil
      #(Time.now + ( 7200 + source.css('.countdown').first['data-time-left'].to_i )).to_date
    end

    def image
      begin
      img = open( source.css('.image_cont img').first['src'] )
      rescue Exception => e
        return nil
      end
      self.image_file = img
    end

    def description
      raw_description = source.css('div[style]')[1].css('p')[1]
      return nil if raw_description.nil? or raw_description.blank?
      raw_description.css('a').each do |a|
         if a['href'] =~ /kupongid/
            a.remove
         else
            a['target'] = 'blank'
            a['rel'] = 'nofollow'
         end
      end
       
      raw_description.to_html.encode('utf-8') rescue nil
    end

    def subway
      sbway = source.css(".address").text.strip.gsub(/\s*-\s*показать/, '').split('|').first
      return nil if sbway.nil? || sbway.gsub(/[ ,-\\"'`]*/, '').empty?

      sbway.strip
    end

    def address
      source.css("div.deal .address").text.strip.gsub(/\s*-\s*показать/, '').split('|').map(&:strip).last
    end

    def provider_url
      begin
        out_page = @@bot.get(source.css(".formbutton").first['href'])
        if out_page.uri.to_s =~ /kupongid/
          out_page.links.last.href.gsub /\?.*/, ''
        else
          out_page.uri.to_s.gsub /\?.*/, ''
        end
      rescue Exception => e
        nil
      end
    end

  end

end
