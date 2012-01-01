require 'nokogiri'
require 'open-uri'
require 'pry'

URL = 'http://www.weclever.ru/xml/openstat/kuponavt.com.xml'

offers = Nokogiri::XML( open URL ).xpath('//offer')

binding.pry

