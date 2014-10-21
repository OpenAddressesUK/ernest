require 'sinatra'
require 'sinatra/activerecord'
require 'require_all'

require_rel '/models'

class Ernest < Sinatra::Base

  post '/address' do
    body = JSON.parse request.body.read

    provenance = create_provenance(body['provenance'])
    @address = Address.new(activity_attributes: provenance)

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
