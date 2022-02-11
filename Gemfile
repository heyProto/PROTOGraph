source 'https://rubygems.org'

git_source(:bitbucket) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://bitbucket.org/#{repo_name}"
end

ruby "2.5.3"

#RAILS
gem 'rails', '~> 5.1.1'
gem 'pg'
gem 'puma', '~> 4.3'

#CORE INFRASTRUCTURE
gem 'friendly_id', '~> 5.1.0'
gem 'dotenv'
gem 'dotenv-rails'
gem 'rest-client'
gem 'best_in_place', '~> 3.0.1'
gem 'kaminari'
gem 'bootstrap4-kaminari-views'
gem "version"
gem 'exception_notification'
gem 'foreman'
gem 'json-schema'
gem 'sidekiq'
gem 'jquery-ui-rails'
gem 'country_select'
gem "intercom-rails"
gem 'ransack'

#AUTHENTICATION
gem 'devise', '>=4.4.0'
gem 'activerecord-session_store'


#VIEWS
gem 'webpacker'
gem 'simple_form', '~> 3.2', '>= 3.2.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'rack-cors', :require => 'rack/cors'
gem 'whenever'

#gem 'rmagick'
gem 'carrierwave'

#Encryption
#gem "attr_encrypted", "~> 3.0.0"
gem 'aws-sdk'
gem 'sitemap_generator'
gem 'geocoder'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem "annotate"
  gem "awesome_print"
  gem "rails-erd"
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'brakeman', :require => false
  # gem 'switch_user'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]