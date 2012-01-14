# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require File.join Rails.root, 'db/seeds/categories'

providers =
  Provider.create([
                  { name: 'biglion',
                    url: 'http://www.biglion.ru',
                    auth_params: {:auth_url=>"http://www.biglion.ru/auth/", :auth_details=>{:email_4=>"kupostat@gmail.com", :password_4=>"cdtnbr1988"}},
                    logo_url: 'biglion.png',
                    ref_url: '/?utm_campaign=PartnerReferral&utm_medium=site&utm_source=p6268090'
                  },
                  { name: 'vigoda',
                    url: 'http://vigoda.ru',
                    logo_url: 'vigoda.png',
                    ref_url: '/?a_aid=kuponavt'
                  },
                  { name: 'myredcat',
                    url: 'http://www.myredcat.ru',
                    logo_url: 'myredcat.png'
                  },
                  { name: 'weclever',
                    url: 'http://www.weclever.ru',
                    logo_url: 'weclever.png'
                  },
                  { name: 'bigbuzzy',
                    url: 'http://bigbuzzy.ru',
                    logo_url: 'bigbuzzy.png'
                  },
                  { name: 'discounter',
                    url: 'http://discounter.pro',
                    logo_url: 'discounter.png',
                  },
                  { name: 'kupikupon',
                    url: 'http://www.kupikupon.ru/',
                    logo_url: 'kupikupon.png'
                  },
                  { name: 'yakupon',
                    url: 'http://yakupon.ru/',
                    logo_url: 'yakupon.png'
                  },
                  { name: 'kupibonus',
                    url: 'http://www.kupibonus.ru/',
                    logo_url: 'kupibonus.png'
                  },
                  { name: 'fun2mass',
                    url: 'http://fun2mass.ru/',
                    logo_url: 'fun2mass.png'
                  },
                  { name: 'discounti',
                    url: 'http://discounti.ru/',
                    logo_url: 'discounti.png'
                  },
                  { name: 'myfant',
                    url: 'http://www.myfant.ru/',
                    logo_url: 'myfant.png'
                  },
                  { name: 'clubkupon',
                    url: 'http://clubkupon.ru/',
                    logo_url: 'clubkupon.png'
                  },
                  { name: 'donkupone',
                    url: 'http://donkupone.ru/',
                    logo_url: 'donkupone.png'
                  },
                  { name: 'alkupone',
                    url: 'http://alkupone.ru/',
                    logo_url: 'alkupone.png'
                  },
                  { name: 'skidkaest',
                    url: 'http://www.skidkaest.ru/',
                    logo_url: 'skidkaest.png'
                  },
                  { name: 'lisalisa',
                    url: 'http://www.lisalisa.ru/',
                    logo_url: 'lisalisa.png'
                  },
                  { name: 'cityradar',
                    url: 'http://cityradar.ru/',
                    logo_url: 'cityradar.png'
                  },
                  { name: 'billkill',
                    url: 'http://www.billkill.ru/',
                    logo_url: 'billkill.png'
                  },
                  { name: 'discount-today',
                    url: 'http://www.discount-today.ru/',
                    logo_url: 'discount-today.png'
                  },
                  { name: 'qpon',
                    url: 'http://qpon.ru/',
                    logo_url: 'qpon.png'
                  },
                  { name: 'ladykupon',
                    url: 'http://ladykupon.ru/',
                    logo_url: 'ladykupon.png'
                  },
                  { name: 'carpot',
                    url: 'http://carpot.ru',
                    logo_url: 'carpot.png'
                  },
                  { name: 'boombate',
                    url: 'http://boombate.com',
                    logo_url: 'boombate.png'
                  },
                  { name: 'hipclub',
                    url: 'http://hipclub.ru',
                    logo_url: 'hipclub.png'
                  },
                  { name: 'sellberry',
                    url: 'http://sellberry.ru',
                    logo_url: 'sellberry.png'
                  },
                  { name: 'funkyworld',
                    url: 'http://funkyworld.ru/',
                    logo_url: 'funkyworld.png'
                  },
                  { name: 'newnotion',
                    url: 'http://www.newnotion.ru',
                    logo_url: 'newnotion.png'
                  },
                  { name: 'kuponya',
                    url: 'http://kuponya.ru/',
                    logo_url: 'kuponya.png'
                  },
                  { name: 'ostrovok',
                    url: 'http://ostrovok.ru/',
                    logo_url: 'ostrovok.png'
                  },
                  { name: 'brandel',
                    url: 'http://www.brandel.ru/',
                    logo_url: 'brandel.png'
                  },
                  { name: 'ckidki',
                    url: 'http://ckidki.ru/',
                    logo_url: 'ckidki.png'
                  },
                  { name: 'vkusoflife',
                    url: 'http://www.vkusoflife.ru/',
                    logo_url: 'vkusoflife.png'
                  },
                  { name: 'saleforman',
                    url: 'http://www.saleforman.ru/',
                    logo_url: 'saleforman.png'
                  },
                  { name: 'planet-eds',
                    url: 'http://planet-eds.ru/',
                    logo_url: 'planet-eds.png'
                  },
                  { name: 'dailysmiles',
                    url: 'http://www.dailysmiles.ru/',
                    logo_url: 'dailysmiles.png'
                  },
                  { name: 'maxbery',
                    url: 'http://maxbery.ru/',
                    logo_url: 'maxbery.png'
                  },
                  { name: 'citycoupon',
                    url: 'http://citycoupon.ru/',
                    logo_url: 'citycoupon.png'
                  },
                  { name: 'mafam',
                    url: 'http://mafam.ru/',
                    logo_url: 'mafam.png'
                  },
                  { name: 'bestkupon',
                    url: 'http://bestkupon.ru/',
                    logo_url: 'bestkupon.png'
                  },
                  { name: 'bonkupon',
                    url: 'http://www.bonkupon.ru/',
                    logo_url: 'bonkupon.png'
                  },
                  { name: 'joybuy',
                    url: 'http://joybuy.ru/',
                    logo_url: 'joybuy.png'
                  },
                  { name: 'megakupon',
                    url: 'http://www.megakupon.ru/',
                    logo_url: 'megakupon.png'
                  },
                  { name: 'obval',
                    url: 'http://www.obval.com/',
                    logo_url: 'obval.png'
                  },
                  { name: 'kingcoupon',
                    url: 'http://kingcoupon.ru/',
                    logo_url: 'kingcoupon.png'
                  },
                  { name: 'darget',
                    url: 'http://darget.ru/',
                    logo_url: 'darget.png'
                  },
                  { name: 'halyavaproject',
                    url: 'http://halyavaproject.ru/',
                    logo_url: 'halyavaproject.png'
                  },
                  { name: 'lotbest',
                    url: 'http://lotbest.ru/',
                    logo_url: 'lotbest.png'
                  },
                  { name: 'skuponom',
                    url: 'http://skuponom.ru/',
                    logo_url: 'skuponom.png'
                  },
                  { name: 'gorodinfo',
                    url: 'http://www.gorodinfo.ru/',
                    logo_url: 'gorodinfo.png'
                  },
                  { name: 'groupon',
                    url: 'http://groupon.ru/',
                    logo_url: 'groupon.png'
                  },
                  { name: 'salesforyou',
                    url: 'http://salesforyou.ru/',
                    logo_url: 'salesforyou.png'
                  },
                  { name: 'megackidki',
                    url: 'http://megackidki.ru/',
                    logo_url: 'megackidki.png'
                  },
                  { name: 'kidskupon',
                    url: 'http://kidskupon.ru/',
                    logo_url: 'kidskupon.png'
                  },
                  { name: 'kupon',
                    url: 'http://kupon.ru/',
                    logo_url: 'kupon.png'
                  },
                  { name: 'hotbaklazhan',
                    url: 'http://hotbaklazhan.ru/',
                    logo_url: 'hotbaklazhan.png'
                  },
                  { name: 'diprice',
                    url: 'http://www.diprice.ru/',
                    logo_url: 'diprice.png'
                  },
                  { name: 'slonkupon',
                    url: 'http://www.slonkupon.ru/',
                    logo_url: 'slonkupon.png'
                  },
                  { name: 'ctwoman',
                    url: 'http://ctwoman.ru/',
                    logo_url: 'ctwoman.png'
                  },
                  { name: 'saynobody',
                    url: 'http://saynobody.ru/',
                    logo_url: 'saynobody.png'
                  },
                  { name: 'mydarin',
                    url: 'http://www.mydarin.ru/',
                    logo_url: 'mydarin.png'
                  },
                  { name: 'azbuka-skidok',
                    url: 'http://azbuka-skidok.ru/',
                    logo_url: 'azbuka-skidok.png'
                  },
                  { name: 'autokupon',
                    url: 'http://autokupon.ru/',
                    logo_url: 'autokupon.png'
                  },
                  { name: 'wildprice',
                    url: 'http://wildprice.ru/',
                    logo_url: 'wildprice.png'
                  },
                  { name: 'glavskidka',
                    url: 'http://glavskidka.ru/',
                    logo_url: 'glavskidka.png'
                  },
                  { name: 'couponhouse',
                    url: 'http://couponhouse.ru/',
                    logo_url: 'couponhouse.png'
                  },
                  { name: '5ine',
                    url: 'http://5ine.ru.com/',
                    logo_url: '5ine.png'
                  },
                  { name: 'skidkumne',
                    url: 'http://skidkumne.ru/',
                    logo_url: 'skidkumne.png'
                  },
                  { name: 'expresskupon',
                    url: 'http://expresskupon.ru/',
                    logo_url: 'expresskupon.png'
                  },
                  { name: 'etook',
                    url: 'http://etook.ru/',
                    logo_url: 'etook.png'
                  },
                  { name: 'shopogoliq',
                    url: 'http://www.shopogoliq.ru/',
                    logo_url: 'shopogoliq.png'
                  },
                  { name: 'bonimani',
                    url: 'http://www.bonimani.ru/',
                    logo_url: 'bonimani.png'
                  },
                  { name: 'bank-skidki',
                    url: 'http://www.bank-skidki.ru/',
                    logo_url: 'bank-skidki.png'
                  },
                  { name: 'viptalon',
                    url: 'http://www.viptalon.ru/',
                    logo_url: 'viptalon.png'
                  },
                  { name: 'izumgoroda',
                    url: 'http://izumgoroda.ru/',
                    logo_url: 'izumgoroda.png'
                  },
                  { name: 'polzagroup',
                    url: 'http://polzagroup.ru/',
                    logo_url: 'polzagroup.png'
                  },
                  { name: 'vacaloca',
                    url: 'http://vacaloca.ru/',
                    logo_url: 'vacaloca.png'
                  },
                  { name: 'kupontravel',
                    url: 'http://www.kupontravel.ru/',
                    logo_url: 'kupontravel.png'
                  },
                  { name: 'vipkupon',
                    url: 'http://vipkupon.ru/',
                    logo_url: 'vipkupon.png'
                  },
                  { name: 'skidogolik',
                    url: 'http://skidogolik.ru/',
                    logo_url: 'skidogolik.png'
                  },
                  { name: 'biglift',
                    url: 'http://biglift.ru/',
                    logo_url: 'biglift.png'
                  },
                  { name: 'restoran-city',
                    url: 'http://restoran-city.ru/',
                    logo_url: 'restoran-city.png'
                  },
                  { name: 'appiny',
                    url: 'http://www.appiny.ru/',
                    logo_url: 'appiny.png'
                  },
                  { name: 'intercoupon',
                    url: 'http://intercoupon.ru/',
                    logo_url: 'intercoupon.png'
                  },
                  { name: 'skidman',
                    url: 'http://skidman.ru/',
                    logo_url: 'skidman.png'
                  },
                  { name: 'kuponid',
                    url: 'http://kuponid.ru/',
                    logo_url: 'kuponid.png'
                  },
                  { name: 'darrom',
                    url: 'http://darrom.ru/',
                    logo_url: 'darrom.png'
                  },
                  { name: 'dealtimes',
                    url: 'http://dealtimes.ru/',
                    logo_url: 'dealtimes.png'
                  },
                  { name: 'pluskupon',
                    url: 'http://www.pluskupon.ru/',
                    logo_url: 'pluskupon.png'
                  },
                  { name: 'city-kupon',
                    url: 'http://www.city-kupon.ru/',
                    logo_url: 'city-kupon.png'
                  },
                  { name: 'pro-cent',
                    url: 'http://pro-cent.ru/',
                    logo_url: 'pro-cent.png'
                  },
                  { name: 'dringo',
                    url: 'http://dringo.ru/',
                    logo_url: 'dringo.png'
                  },
                  { name: 'bankskidok',
                    url: 'http://bankskidok.com/',
                    logo_url: 'bankskidok.png'
                  },
                  { name: 'kupiotpusk',
                    url: 'http://kupiotpusk.ru/',
                    logo_url: 'kupiotpusk.png'
                  },
                  { name: 'sugarsales',
                    url: 'http://sugarsales.ru/',
                    logo_url: 'sugarsales.png'
                  },
                  { name: 'bontalon',
                    url: 'http://bontalon.ru/',
                    logo_url: 'bontalon.png'
                  },
                  { name: 'bigsaving',
                    url: 'http://bigsaving.ru/',
                    logo_url: 'bigsaving.png'
                  },
                  { name: 'skidka50',
                    url: 'http://skidka50.ru/',
                    logo_url: 'skidka50.png'
                  },
                  { name: 'bonusprice',
                    url: 'http://bonusprice.ru/',
                    logo_url: 'bonusprice.png'
                  }

  ])

countries =
  Country.create([
                 { name: 'ukraine',
                   currency: 'грн'
                 },
                 { name: 'russia',
                   currency: 'руб'
                 }
  ])

ukraine_id = Country.find_by_name('ukraine').id
russia_id = Country.find_by_name('russia').id

es =

  City.create([
              { name: 'kiev',
                country_id: ukraine_id
              },
              { name: 'moskva',
                country_id: russia_id
              },
              { name: 'sankt-peterburg',
                country_id: russia_id
              },
              { name: 'almetyevsk',
                country_id: russia_id
              },
              { name: 'arkhangelsk',
                country_id: russia_id
              },
              { name: 'astrakhan',
                country_id: russia_id
              },
              { name: 'balakovo',
                country_id: russia_id
              },
              { name: 'baltiysk',
                country_id: russia_id
              },
              { name: 'barnaul',
                country_id: russia_id
              },
              { name: 'belgorod',
                country_id: russia_id
              },
              { name: 'bryansk',
                country_id: russia_id
              },
              { name: 'veliky-novgorod',
                country_id: russia_id
              },
              { name: 'vladivostok',
                country_id: russia_id
              },
              { name: 'vladikavkaz',
                country_id: russia_id
              },
              { name: 'vladimir',
                country_id: russia_id
              },
              { name: 'volgograd',
                country_id: russia_id
              },
              { name: 'volzhsky',
                country_id: russia_id
              },
              { name: 'vologda',
                country_id: russia_id
              },
              { name: 'voronezh',
                country_id: russia_id
              },
              { name: 'dmitrovgrad',
                country_id: russia_id
              },
              { name: 'yeisk',
                country_id: russia_id
              },
              { name: 'yekaterinburg',
                country_id: russia_id
              },
              { name: 'ivanovo',
                country_id: russia_id
              },
              { name: 'izhevsk',
                country_id: russia_id
              },
              { name: 'irkutsk',
                country_id: russia_id
              },
              { name: 'yoshkar-ola',
                country_id: russia_id
              },
              { name: 'kazan',
                country_id: russia_id
              },
              { name: 'kaliningrad',
                country_id: russia_id
              },
              { name: 'kaluga',
                country_id: russia_id
              },
              { name: 'kamensk-uralskiy',
                country_id: russia_id
              },
              { name: 'kemerovo',
                country_id: russia_id
              },
              { name: 'kirov',
                country_id: russia_id
              },
              { name: 'komsomolsk-na-amure',
                country_id: russia_id
              },
              { name: 'kostroma',
                country_id: russia_id
              },
              { name: 'krasnodar',
                country_id: russia_id
              },
              { name: 'krasnoyarsk',
                country_id: russia_id
              },
              { name: 'kurgan',
                country_id: russia_id
              },
              { name: 'kursk',
                country_id: russia_id
              },
              { name: 'lipetsk',
                country_id: russia_id
              },
              { name: 'magadan',
                country_id: russia_id
              },
              { name: 'magnitogorsk',
                country_id: russia_id
              },
              { name: 'makhachkala',
                country_id: russia_id
              },
              { name: 'mineralnye-vody',
                country_id: russia_id
              },
              { name: 'murmansk',
                country_id: russia_id
              },
              { name: 'murom',
                country_id: russia_id
              },
              { name: 'naberezhnye-chelny',
                country_id: russia_id
              },
              { name: 'nalchik',
                country_id: russia_id
              },
              { name: 'nizhnevartovsk',
                country_id: russia_id
              },
              { name: 'nizhnekamsk',
                country_id: russia_id
              },
              { name: 'nijnii-novgorod',
                country_id: russia_id
              },
              { name: 'nizhnij-tagil',
                country_id: russia_id
              },
              { name: 'novokuznetsk',
                country_id: russia_id
              },
              { name: 'novorossiysk',
                country_id: russia_id
              },
              { name: 'novosibirsk',
                country_id: russia_id
              },
              { name: 'omsk',
                country_id: russia_id
              },
              { name: 'orel',
                country_id: russia_id
              },
              { name: 'orenburg',
                country_id: russia_id
              },
              { name: 'penza',
                country_id: russia_id
              },
              { name: 'perm',
                country_id: russia_id
              },
              { name: 'petrozavodsk',
                country_id: russia_id
              },
              { name: 'podolsk',
                country_id: russia_id
              },
              { name: 'pskov',
                country_id: russia_id
              },
              { name: 'pyatigorsk',
                country_id: russia_id
              },
              { name: 'rostov',
                country_id: russia_id
              },
              { name: 'rostov-na-donu',
                country_id: russia_id
              },
              { name: 'ryazan',
                country_id: russia_id
              },
              { name: 'samara',
                country_id: russia_id
              },
              { name: 'saransk',
                country_id: russia_id
              },
              { name: 'saratov',
                country_id: russia_id
              },
              { name: 'smolensk',
                country_id: russia_id
              },
              { name: 'solikamsk',
                country_id: russia_id
              },
              { name: 'sochi',
                country_id: russia_id
              },
              { name: 'stavropol',
                country_id: russia_id
              },
              { name: 'sterlitamak',
                country_id: russia_id
              },
              { name: 'surgut',
                country_id: russia_id
              },
              { name: 'siktivkar',
                country_id: russia_id
              },
              { name: 'taganrog',
                country_id: russia_id
              },
              { name: 'tambov',
                country_id: russia_id
              },
              { name: 'tver',
                country_id: russia_id
              },
              { name: 'tolyatti',
                country_id: russia_id
              },
              { name: 'tomsk',
                country_id: russia_id
              },
              { name: 'tula',
                country_id: russia_id
              },
              { name: 'tyumen',
                country_id: russia_id
              },
              { name: 'ulanude',
                country_id: russia_id
              },
              { name: 'ulyanovsk',
                country_id: russia_id
              },
              { name: 'ust-labinsk',
                country_id: russia_id
              },
              { name: 'ufa',
                country_id: russia_id
              },
              { name: 'khabarovsk',
                country_id: russia_id
              },
              { name: 'hantimansiysk',
                country_id: russia_id
              },
              { name: 'cheboksary',
                country_id: russia_id
              },
              { name: 'cheliabinsk',
                country_id: russia_id
              },
              { name: 'cherepovets',
                country_id: russia_id
              },
              { name: 'chita',
                country_id: russia_id
              },
              { name: 'engels',
                country_id: russia_id
              },
              { name: 'yuzhno-sahalinsk',
                country_id: russia_id
              },
              { name: 'yakutsk',
                country_id: russia_id
              },
              { name: 'yaroslavl',
                country_id: russia_id
              },
              { name: 'kiev',
                country_id: ukraine_id
              },
              { name: 'vinnitsa',
                country_id: ukraine_id
              },
              { name: 'dnepropetrovsk',
                country_id: ukraine_id
              },
              { name: 'doneck',
                country_id: ukraine_id
              },
              { name: 'zaporozhye',
                country_id: ukraine_id
              },
              { name: 'ivano-frankovsk',
                country_id: ukraine_id
              },
              { name: 'krivoy-rog',
                country_id: ukraine_id
              },
              { name: 'lugansk',
                country_id: ukraine_id
              },
              { name: 'lvov',
                country_id: ukraine_id
              },
              { name: 'makeevka',
                country_id: ukraine_id
              },
              { name: 'mariupol',
                country_id: ukraine_id
              },
              { name: 'nikolaev',
                country_id: ukraine_id
              },
              { name: 'odessa',
                country_id: ukraine_id
              },
              { name: 'poltava',
                country_id: ukraine_id
              },
              { name: 'sevastopol',
                country_id: ukraine_id
              },
              { name: 'simferopol',
                country_id: ukraine_id
              },
              { name: 'ternopol',
                country_id: ukraine_id
              },
              { name: 'feodosiya',
                country_id: ukraine_id
              },
              { name: 'kharkov',
                country_id: ukraine_id
              },
              { name: 'kherson',
                country_id: ukraine_id
              }
  ])

#cities =
  #City.create([
              #{ name: 'kiev',
                #country_id: ukraine_id
              #},
              #{ name: 'moskva',
                #country_id: russia_id
              #}
  #])

# CATEGORIES
categories = $categories

#categories = [
  #{ name: "Еда и Развлечения", nested_categories: [
                                 #{ name: "Кафе, рестораны" },
                                 #{ name: "Вечеринки, клубы" },
                                 #{ name: "Боулинг, бильярд" },
                                 #{ name: "Кино, концерты" },
                                 #{ name: "Театры, экскурсии" },
                                 #{ name: "Активный отдых" },
                                 #{ name: "Отели, путешествия" }
                               #]
  #},
  #{ name: "Красота и Здоровье", nested_categories: [
                                  #{ name: "Здоровье, медицина" },
                                  #{ name: "Красота, уход" },
                                  #{ name: "Спорт, танцы" }
                                #]
  #},
  #{ name: "Обучение", nested_categories: [
                        #{ name: "Обучение, курсы" },
                      #]
  #},
  #{ name: "Товары и Услуги", nested_categories: [
                               #{ name: "Магазины, распродажи" },
                               #{ name: "Фото, видео" },
                               #{ name: "Автомобили, мойки" },
                               #{ name: "Дом, уют" },
                               #{ name: "Дети, семья" },
                               #{ name: "Животные" },
                               #{ name: "Бизнес" }
                             #]
  #},
  #{ name: "Прочее", nested_categories: [
                      #{ name: "Все" }
                    #]
  #}
#]

categories.each do |parent_category|
  nested_categories = parent_category.delete(:nested_categories)
  category = Category.create( parent_category )
  nested_categories.map! { |attributes| attributes.merge({ parent_category_id: category.id }) }

  Category.create( nested_categories )
end
