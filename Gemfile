source 'https://rubygems.org/'
ruby '2.4.0'

gem 'rails', '5.0.2'
gem 'pg', '~> 0.15'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'listen'
gem 'bcrypt'
gem 'jwt'
gem 'httparty'
gem 'rack-cors', require: 'rack/cors'

group :development, :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'pry-rails'
  gem 'shoulda'
  gem 'valid_attribute'
  gem 'dotenv-rails'
end

group :test do
  gem 'launchy', require: false
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end
