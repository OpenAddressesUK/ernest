require 'sinatra'
require 'sinatra/activerecord'
require 'require_all'
require 'resque'
require 'dotenv'

require_rel '/models'
Dotenv.load
Resque.redis = ENV['REDIS_TOGO_URL']

class Ernest < Sinatra::Base

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

    provenance = create_provenance(body['provenance'])
    @address = Address.new(activity_attributes: provenance)
    @address.user = @user

    body['address'].each do |type, label|
      tag_type = TagType.find_or_create_by(label: type)
      @address.tags << Tag.create(label: label,
                                  tag_type: tag_type,
                                  activity_attributes: provenance)
    end

    if @address.save
      return 201
    else
      return 500
    end
  end

  private

    def create_provenance(provenance)
      {
        executed_at: provenance['executed_at'],
        derivations: [
          Derivation.create(entity: Source.find_or_create_by(url: provenance['url']))
        ]
      }
    end

end
