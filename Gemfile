source 'https://rubygems.org'
ruby "2.7.7"

gem 'rails', '5.1.1'
gem "pg", '~> 0.20.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem "bower-rails", '~> 0.11.0'
gem 'font-awesome-rails'
gem 'foreman'
gem 'angular-rails-templates'
gem 'haml'
gem 'responders'
gem 'devise', '~> 4.4.0'
gem 'rolify'
gem 'cancancan', '~> 1.10'
gem 'passenger', '~> 5.1'
gem 'active_model_serializers'
gem 'active_record_union'
gem 'hashie'
gem 'clean_pagination', git: 'https://github.com/jonuts/clean_pagination', branch: 'config'
gem 'prawn', '~> 2.1'
gem 'prawn-table'
gem 'sablon'
gem 'sidekiq', '~> 4.2.9'
gem 'sendinc', '0.2.2', git: 'https://github.com/jonuts/sendinc'
gem 'rubyzip', '> 1.0.0'
gem 'validates_email_format_of', '~> 1.6'
gem 'whenever', require: false
gem 'net-sftp'
gem 'sentry-raven', '~> 2.5.1'
gem 'aws-sdk'
gem 'public_suffix'
gem 'figaro'
gem 'tzinfo-data'
gem 'audited'
gem 'countries', require: 'countries/global'

# Added to keep rails-5.1 upgrade happy
gem 'erubis'

group :staging do
  gem "rails_12factor"
  gem "rails_stdout_logging"
  gem "rails_serve_static_assets"
end

group :doc do
  gem 'sdoc', '1.0.0.rc2', require: false
end

group :development, :test do
  gem 'byebug'
  gem "rspec-rails", "~> 4.0"
  gem "factory_girl_rails", "~> 4.0"
  gem "capybara"
  gem "database_cleaner"
  gem "selenium-webdriver"
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-coolline'
  gem 'faker', git: "https://github.com/stympy/faker"
end

group :development do
  # gem 'rack-mini-profiler'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'guard-livereload'
  # gem 'guard-rspec', '~> 4.7.2', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

