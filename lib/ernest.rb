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
      @token = request.env["HTTP_ACCESS_TOKEN"]
      ENV['ERNEST_ALLOWED_KEYS'].split(",").include?(@token)
    end
  end

  post '/addresses', check: :valid_key? do
    body = request.body.read
    return 400 if body.blank?

    body = JSON.parse body

    CreateAddress.perform_async(body, @token)

    return 202
  end

  get '/addresses' do
    content_type :json

    if params[:updated_since]
      address = Address.where('updated_at >= ?', params[:updated_since])
    else
      address = Address.all
    end

    page = address.page(params[:page].to_i)
    addresses = []

    page.each do |a|
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
      pages: page.total_pages,
      total: page.total_count,
      addresses: addresses
    }.to_json
  end
end
