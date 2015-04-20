require 'iron_mq'
require 'dotenv'

Dotenv.load

class ImportAddresses

  def self.create_address address
  #  address = JSON.parse(body)

    provenance = create_provenance(address['provenance'])
    a = Address.new(activity_attributes: provenance)

    ['saon', 'paon', 'street', 'locality', 'town', 'postcode'].each do |type|
      tag_type = TagType.find_or_create_by(label: type)
      a.tags << Tag.create(
                           label: address[type],
                           tag_type: tag_type,
                           activity_attributes: provenance
                          )
    end

    a.save
  end

  def self.create_provenance(provenance)
    prov = {
      executed_at: provenance['activity']['executed_at'],
      processing_script: provenance['activity']['processing_scripts'],
      derivations: []
    }

    provenance['activity']['derived_from'].each do |p|
      activity = Activity.create(
        processing_script: p["processing_script"],
        executed_at: p["downloaded_at"] || p["inputted_at"] || p["inferred_at"]
      )

      if p['type'] == "Source"
        source = Source.find_or_create_by(input: p['urls'].first, kind: "url", activity: activity)
      elsif p['type'] == "inference"
        source = Source.create(input: p['inferred_from'].join(','), kind: "inference", activity: activity)
      else
        source = Source.create(input: p['input'], kind: "userInput", activity: activity)
      end

      prov[:derivations] << Derivation.create(entity: source)
    end

    prov
  end

end
