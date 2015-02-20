require "sinatra/activerecord/rake"
require "./lib/ernest"
require "./lib/jobs/import_addresses"
require "./lib/jobs/import_public_addresses"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

namespace :ernest do
  task :import do
    ImportPublicAddresses.perform
  end
end

task :default => :spec
