require 'sinatra'
require 'sinatra/activerecord'
require 'require_all'
require 'resque'
require 'dotenv'

require_rel '/models'
require_rel '/jobs'

Dotenv.load
Resque.redis = ENV['REDIS_TOGO_URL']

class Ernest < Sinatra::Base

  if ENV["RACK_ENV"]=='production'
    require 'raygun4ruby'
    Raygun.setup do |config|
     config.api_key = ENV["RAYGUN_API_KEY"]
    end
    use Raygun::Middleware::RackExceptionInterceptor
  end

  register do
    def check (name)
      condition do
        error 401 unless send(name) == true
      end
    end
  end

  helpers do
    def valid_key?
      @user = User.find_by_api_key(request.env["HTTP_ACCESS_TOKEN"])
      !@user.nil?
    end
  end

  post '/address', check: :valid_key? do
    body = JSON.parse request.body.read

    Resque.enqueue(CreateAddress, body, @user.id)

    return 202
  end
  
end
