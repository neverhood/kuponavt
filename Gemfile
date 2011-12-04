source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'rack' , '1.3.3' # Bye Bye warning

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Db
gem 'sqlite3'
gem 'mysql2'

# Xml & Html parser
gem 'hpricot'

# Image processor
gem 'carrierwave'
gem 'rmagick'

# Pagination
gem 'kaminari'

# Parser
gem 'mechanize'

# REPL
gem 'pry-rails'

# YAML DB
gem 'yaml_db'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
#  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'rails3-generators'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'spork', '~> 0.9.0.rc'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'faker'
  # Some spork info:
  #   spork --bootstrap
  #   edit spec_helper.rb: wrap the old contents in prefork or each_run blocks
  #   comment out `require rubygems` - no need for that since we're using bundler
  #   add '--drb' to .rspec
  #   start spork with `spork` command
  #   yeah!
end


# Gems to serve testing purposes
# Cucumber will be used to write acceptance scenarios( using the rspec/capybara matchers )
# Rspec is used for the rest
group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

# JS Framework
gem 'jquery-rails'

# Authentication
gem 'devise'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

