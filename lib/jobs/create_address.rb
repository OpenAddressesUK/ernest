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
    source  = nil
    if provenance['url']
      source = Source.find_or_initialize_by(input: provenance['url']) do |source|
        source.kind = 'url'
      end
    elsif provenance['userInput']
      source = Source.find_or_initialize_by(input: provenance['userInput']) do |source|
        source.kind = 'userInput'
      end
    end
    if source
      source.activity_attributes = {
        executed_at: provenance['executed_at']
      }
      source.save!
    end
    {
      executed_at: provenance['executed_at'],
      attribution: provenance['attribution'],
      processing_script: provenance['processing_script'],
      derivations: source ? [Derivation.create(entity: source)] : []
    }
  end
end
