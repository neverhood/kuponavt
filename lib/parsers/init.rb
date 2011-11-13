# coding: utf-8
require 'mechanize'
require 'pry'
require 'active_record'

$rails_root = (ENV['RAILS_ROOT'] || File.expand_path('../../../', __FILE__))
$LOAD_PATH << $rails_root

$db_config = YAML::load( File.open('config/database.yml') )
ActiveRecord::Base.establish_connection($db_config['development'])

$agent = Mechanize.new
