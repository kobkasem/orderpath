source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 7.1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.0'
gem 'httparty', '~> 0.21.0'
gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw], require: false
  gem 'rspec-rails', '~> 6.0', require: false
  gem 'factory_bot_rails', '~> 6.2', require: false
end

group :development do
  gem 'web-console', '>= 4.2.0', require: false
  gem 'listen', '~> 3.3', require: false
  gem 'spring', require: false
end


