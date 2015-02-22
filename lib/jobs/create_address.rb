class CreateAddress
  include Sidekiq::Worker

  def perform(body, token)
    ActiveRecord::Base.transaction do
      body['addresses'].each do |a|
        provenance = create_provenance(a['provenance'])
        address = Address.new(activity_attributes: provenance)
        address.user = User.find_by_api_key(token)

        a['address'].each do |type, label|
          tag_type = TagType.find_or_create_by(label: type)
          point = label["geometry"].nil? ? nil : "POINT (#{label["geometry"]["coordinates"].join(" ")})"
          address.tags << Tag.create(label: label["name"],
                                      tag_type: tag_type,
                                      activity_attributes: provenance,
                                      point: point)
        end

        address.save
      end
    end
  end

  def create_provenance(provenance)
    {
      executed_at: provenance['executed_at'],
      attribution: provenance['attribution'],
      processing_script: provenance['processing_script'],
      derivations: [
        Derivation.create(entity: Source.find_or_create_by(input: provenance['url']))
      ]
    }
  end
end
