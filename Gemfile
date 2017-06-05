source 'https://rubygems.org'

gemspec

gem 'grape', '~> 0.16'
gem 'rack-oauth2', git: 'https://github.com/parity/rack-oauth2.git'

gem 'activerecord'
gem 'bcrypt'

group :test do
  platforms :ruby, :mswin, :mswin64, :mingw, :x64_mingw do
    gem 'sqlite3'
  end

  gem 'rspec-rails', '~> 3.5'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'rack-test', require: 'rack/test'
  gem 'otr-activerecord'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
