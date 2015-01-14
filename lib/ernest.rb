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

    begin
      body = JSON.parse body
    rescue JSON::ParserError
      return 400
    end

    CreateAddress.perform_async(body, @token)

    return 202
  end

  get '/addresses' do
    content_type :json

    if params[:updated_since]
      begin
        updated = DateTime.parse(params[:updated_since])
      rescue
        return 400
      end
      address = Address.where('updated_at >= ?', updated)
    else
      address = Address.all
    end

    page = address.page(params[:page].to_i)
    addresses = []

    page.each do |a|
      addresses << address_data(a)
    end

    {
      current_page: (params[:page] || 1).to_i,
      pages: page.total_pages,
      total: page.total_count,
      addresses: addresses
    }.to_json
  end

  get '/addresses/:id' do
    content_type :json
    a = Address.find(params[:id])
    address_data(a).to_json
  end

  def address_data(a)
    h = {}
    h["url"] = "http://ernest.openaddressesuk.org/addresses/#{a.id}"
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
    fixed_provenance_sources = JSON.parse(File.read('config/fixed_provenance_sources.json'))
    h['provenance'] = {
      activity: {
        processing_script: "https://github.com/OpenAddressesUK/common-ETL/blob/efcd9970fc63c12b2f1aef410f87c2dcb4849aa3/CH_Bulk_Extractor.py",
        executed_at: a.activity.executed_at,
        derived_from: fixed_provenance_sources
      }
    }
    h
  end

end
