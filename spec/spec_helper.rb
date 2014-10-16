# spec/spec_helper.rb
require 'rack/test'
require 'pry'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../ernest.rb', __FILE__

require 'simplecov'
SimpleCov.start

ActiveRecord::Base.logger.level = 1

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|

  config.include RSpecMixin

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
