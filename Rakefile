require "sinatra/activerecord/rake"
require "./lib/ernest"
require "./lib/jobs/import_addresses"
require "./lib/jobs/import_public_addresses"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :ernest do
  namespace :import do
    task :public do
      ImportPublicAddresses.perform
    end

    task :turbot do
      ImportTurbotAddresses.perform
    end
  end
end

task :default => :spec
