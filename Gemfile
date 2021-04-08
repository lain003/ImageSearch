source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'rspec-rails'

  gem 'debase'
  gem 'ruby-debug-ide'

  gem 'regexp_parser', '>= 1.8'
  gem 'rubocop', '~> 1.10', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  gem 'rails-controller-testing'

  gem 'webdrivers', '~> 4.0'

  gem 'rspec_junit_formatter'
end

group :development do
  gem 'annotate'

  gem 'bullet'
  gem 'ruby_gntp'

  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-rails', '~> 1.4', require: false

  gem 'brakeman', require: false
end

gem 'google-cloud-storage'
gem 'google-cloud-vision'
gem 'mysql2'

gem 'kaminari'

# https://ulab.hatenablog.com/entry/20191013/1570930332と同じエラーが出た為、version down
gem 'elasticsearch-model', git: 'https://github.com/elastic/elasticsearch-rails.git', branch: '6.x'
gem 'elasticsearch-rails', git: 'https://github.com/elastic/elasticsearch-rails.git', branch: '6.x'

gem 'config'

gem 'fastimage'

gem 'sitemap_generator'

gem 'react-rails'
gem 'webpacker'

gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'

gem 'js-routes'

gem 'natto'

gem 'rb-readline'