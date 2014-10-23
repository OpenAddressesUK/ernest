require "sinatra/activerecord/rake"
require "resque/tasks"
require "./lib/ernest"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :resque do
  task :setup do
    if ENV['RACK_ENV']=="production"
      # Set up failure notifications
      require 'raygun4ruby'
      require 'resque/failure/multiple'
      require 'resque/failure/raygun'
      require 'resque/failure/redis'

      Raygun.setup do |config|
        config.api_key = ENV["RAYGUN_API_KEY"]
        config.enable_reporting = true
      end

      Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Raygun]
      Resque::Failure.backend = Resque::Failure::Multiple
    end

  end
end