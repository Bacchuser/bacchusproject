source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Authentification, OWASP okay
gem 'devise'

# Use SCSS for stylesheets
gem "sass-rails", "~> 4.0.2"
gem 'sprockets', '<= 2.11.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'

# Manage role and permission ORM independant's way
gem 'authority'

# Capistrano compatible net-ssh version
#gem 'net-ssh', '~> 2.8.1'

group :development do
    # Slim, for badass HTML compilation
    # Syntaxe here : https://github.com/slim-template/slim
    gem 'slim-rails', require: true
    # Debugging purpose
    gem 'better_errors'
    gem 'binding_of_caller'
    # Deployement
    gem 'capistrano'
    gem 'capistrano-rvm', github: 'capistrano/rvm'
    gem 'rvm-capistrano'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

