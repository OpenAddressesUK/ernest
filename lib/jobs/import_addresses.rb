require 'iron_mq'
require 'dotenv'

Dotenv.load

class ImportAddresses

  def self.perform
    @msg = queue.get

    while !@msg.nil? do
      address = JSON.parse(@msg.body)

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

      @msg.delete
      @msg = queue.get
    end
  end

  def self.ironmq
    @@ironmq ||= IronMQ::Client.new(token: ENV['IRON_MQ_TOKEN'], project_id: ENV['IRON_MQ_PROJECT_ID'], host: 'mq-aws-eu-west-1.iron.io')
  end

  def self.queue
    ironmq.queue(ENV['IRON_MQ_QUEUE'])
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
        executed_at: p["downloaded_at"] || p["inputted_at"]
      )

      if p['type'] == "Source"
        source = Source.find_or_create_by(input: p['urls'].first, kind: "url", activity: activity)
      else
        source = Source.create(input: p['input'], kind: "userInput", activity: activity)
      end

      prov[:derivations] << Derivation.create(entity: source)
    end

    prov
  end

end