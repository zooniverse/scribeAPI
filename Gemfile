source 'https://rubygems.org'

ruby '2.2.10'

gem 'rails', '4.0.13'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'devise'
gem 'omniauth-facebook'
gem "omniauth-google-oauth2"
gem 'omniauth-zooniverse', '~> 0.0.3'
gem 'mongoid', '~> 5.2', '>= 5.2.1'
gem 'mongo', '2.4.1'
gem 'active_model_serializers'
gem 'mongoid-serializer'
gem 'rack-cors', :require => 'rack/cors'
gem "bson"
gem "moped"
gem 'browserify-rails', '~> 0.9.1'
gem 'react-rails', '~> 1.0.0.pre', github: 'reactjs/react-rails'

gem 'rack-streaming-proxy', '~> 2.0.1'
gem 'kaminari'
gem 'fastimage', '1.7.0'

gem 'actionpack-action_caching'

gem 'newrelic_rpm'
gem 'newrelic_moped'

gem 'puma', '~> 2.14.0'

gem 'logstasher', '~> 0.6'

group :development do
  gem 'dotenv-rails'
end

group :development, :production do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'quiet_assets'
  gem 'rails_layout'
end

group :assets do
  gem 'jquery-ui-sass-rails'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', :require=>false
  gem 'database_cleaner', '1.0.1'
  gem 'rspec-rails', '~> 3.6'
  gem 'shoulda-matchers'
  gem 'email_spec'
  gem 'launchy'
  gem 'factory_girl'
  gem 'mongoid-rspec', '3.0.0'
end
