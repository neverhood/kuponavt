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
                  { name: 'weclever',
                    url: 'http://www.weclever.ru',
                    logo_url: 'weclever.png'
                  },
                  { name: 'bigbuzzy',
                    url: 'http://bigbuzzy.ru',
                    logo_url: 'bigbuzzy.png'
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

cities =
  City.create([
              { name: 'kiev',
                country_id: ukraine_id
              },
              { name: 'moskva',
                country_id: russia_id
              }
  ])

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
