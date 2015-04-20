require 'jiffybag'
JiffyBag.configure %w{
  RAYGUN_API_KEY
  IRON_MQ_QUEUE
  IRON_MQ_TURBOT_QUEUE
  IRON_MQ_TOKEN
  IRON_MQ_PROJECT_ID
  ERNEST_ALLOWED_KEYS
}

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cross_origin'
require 'require_all'
require 'sidekiq'
require 'json'
require 'kaminari/sinatra'

require_rel '/models'
require_rel '/jobs'



Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_TOGO_URL'] }
end
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_TOGO_URL'] }
end

require 'raygun4ruby'
require 'raygun/sidekiq'
Raygun.setup do |config|
 config.api_key = JiffyBag["RAYGUN_API_KEY"]
end

class Ernest < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '../public'

  register Sinatra::CrossOrigin
  enable :cross_origin

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
      JiffyBag['ERNEST_ALLOWED_KEYS'].split(",").include?(@token)
    end
  end

  post '/addresses', check: :valid_key? do
#    body = request.body.read
#    return 400 if body.blank?

#    begin
#      body = JSON.parse body
#    rescue JSON::ParserError
#      return 400
#    end
    body = json_parse request
    return 400 if body.nil?

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

  get '/' do
    send_file "public/index.html"
  end

  get '/addresses/:id' do
    content_type :json
    a = Address.find(params[:id])
    address_data(a).to_json
  end

  post '/confidence' do
    content_type :json

    body = json_parse request

    address = Address.new
    address.valid_at = body['valid_at']

    body.except('valid_at').each do |type, label|
      tag_type = TagType.find_or_create_by(label: type)
      address.tags << Tag.new(label: label, tag_type: tag_type)
    end

    {
      address: body,
      confidence: address.generate_score
    }.to_json
  end

  options '/addresses/:id/validations' do
    cross_origin
    content_type :json
  end

  post '/addresses/:id/validations' do
    cross_origin
    content_type :json
    a = Address.find(params[:id])

    body = json_parse request
    return 400 if body.nil?

    options = {}
    options[:timestamp] = DateTime.parse body['timestamp'] if body['timestamp']
    options[:attribution] = body['attribution'] if body['attribution']
    options[:reason] = body['reason'] if body['reason']

    return 400 if not [true, false].include? body['exists']

    a.validate! body['exists'], options
    return 201
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
    if a.activity.executed_at.year == 2014
      fixed_provenance_sources = JSON.parse(File.read('config/fixed_provenance_sources.json'))
      h['provenance'] = {
        activity: {
          processing_script: "https://github.com/OpenAddressesUK/common-ETL/blob/efcd9970fc63c12b2f1aef410f87c2dcb4849aa3/CH_Bulk_Extractor.py",
          executed_at: a.activity.executed_at,
          derived_from: fixed_provenance_sources
        }
      }
    else
      h['provenance'] = get_provenance(a)
    end
    h
  end

  def get_provenance(a)
    derivations = a.activity.derivations.map do |d|
      h = {
        type: d.entity.kind,
        executed_at: d.entity.activity.executed_at,
        processing_script: d.entity.activity.processing_script
      }

      case d.entity.kind
      when 'url'
        h[:urls] = [d.entity.input]

      when 'userInput'
        h[:input] = d.entity.input

      when 'inference'
        h[:inferred_from] = d.entity.input.split(',')

      end

    #  d.entity.kind == "url" ? h[:urls] = [d.entity.input] : h[:input] = d.entity.input
      h
    end

    {
      activity: {
        processing_script: a.activity.processing_script,
        executed_at: a.activity.executed_at,
        derived_from: derivations
      }
    }
  end

  def json_parse request
    body = request.body.read
    return nil if body.blank?

    begin
      body = JSON.parse body
    rescue JSON::ParserError
      return nil
    end

    body
  end
end
