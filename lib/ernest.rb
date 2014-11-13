require 'sinatra'
require 'sinatra/activerecord'
require 'require_all'
require 'sidekiq'
require 'dotenv'
require 'json'
require 'kaminari/sinatra'

require_rel '/models'
require_rel '/jobs'

Dotenv.load
Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_TOGO_URL'] }
end
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_TOGO_URL'] }
end

require 'raygun4ruby'
require 'raygun/sidekiq'
Raygun.setup do |config|
 config.api_key = ENV["RAYGUN_API_KEY"]
end

class Ernest < Sinatra::Base

  if ENV["RACK_ENV"]=='production'
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

  post '/addresses', check: :valid_key? do
    body = JSON.parse request.body.read

    CreateAddress.perform_async(body, @user.id)

    return 202
  end

  get '/addresses' do
    content_type :json

    addresses = []

    Address.page(params[:page].to_i).all.each do |a|
      h = {}
      TagType::ALLOWED_LABELS.each do |l|
        h[l] = {}
        h[l]["name"] = a.send(l).try(:label)
        point = a.send(l).try(:point)
        unless point.nil? || point.to_s == "POINT (0.0 0.0)"
          h[l]["geometry"] = {}
          h[l]["geometry"]["type"] = "Point"
          h[l]["geometry"]["coordinates"] = [point.y, point.x]
        end
      end
      addresses << h
    end

    {
      current_page: (params[:page] || 1).to_i,
      pages: (Address.count / 25.0).ceil,
      total: Address.count,
      addresses: addresses
    }.to_json
  end
end
