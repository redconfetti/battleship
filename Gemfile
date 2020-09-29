source 'https://rubygems.org'
ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use postgres as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Flexible authentication solution for Rails
# https://github.com/plataformatec/devise
gem 'devise'

# Bundler-like DSL + rake tasks for Bower on Rails
# https://github.com/rharriso/bower-rails/
gem 'bower-rails'

# Use your angular templates with rails' asset pipeline
# https://github.com/pitr/angular-rails-templates
gem 'angular-rails-templates'

# Extends Rails CSRF protection to play nicely with AngularJS
# https://github.com/Sinbadsoft/angular_csrf
gem 'angular_csrf'

# Needed for compatibility with angular-rails-templates
gem 'sprockets', '2.12.5'

# Manage Procfile-based applications
gem "foreman"

# Ruby Web Server Built For Concurrency
# https://github.com/puma/puma
gem 'puma'

# Ruby library for the Pusher API
# https://github.com/pusher/pusher-http-ruby
gem 'pusher'

group :production, :staging do
  gem "rails_12factor"
  gem "rails_stdout_logging"
  gem "rails_serve_static_assets"
end

group :development, :test do
  # Testing framework for Rails 3.x and 4.x
  # https://github.com/rspec/rspec-rails
  gem 'rspec-rails'

  # A library for setting up Ruby objects as test data
  # https://github.com/thoughtbot/factory_girl
  gem "factory_girl_rails", "~> 4.0"

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

