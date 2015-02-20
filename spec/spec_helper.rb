# spec/spec_helper.rb
require 'rack/test'
require 'pry'
require 'database_cleaner'
require 'factory_girl'
require "rspec-sidekiq"
require 'date'
require 'timecop'
require 'vcr'
require 'dotenv'

require 'ernest'

VCR.configure do |config|
  # Automatically filter all secure details that are stored in the environment
  JiffyBag.variables.each do |key|
    config.filter_sensitive_data("<#{key}>") { JiffyBag[key] }
  end
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../lib/ernest.rb', __FILE__

require 'simplecov'
SimpleCov.start

ActiveRecord::Base.logger.level = 1

module RSpecMixin
  include Rack::Test::Methods
  def app() Ernest end
end

RSpec::Sidekiq.configure do |config|
  config.clear_all_enqueued_jobs = true
  config.enable_terminal_colours = true
  config.warn_when_jobs_not_processed_by_sidekiq = true
end

RSpec.configure do |config|

  config.include RSpecMixin
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.find_definitions

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
