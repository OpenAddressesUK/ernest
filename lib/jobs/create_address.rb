class CreateAddress
  @queue = :default

  def self.perform(body, user_id)
    provenance = create_provenance(body['provenance'])
    address = Address.new(activity_attributes: provenance)
    address.user = User.find(user_id)

    body['address'].each do |type, label|
      tag_type = TagType.find_or_create_by(label: type)
      address.tags << Tag.create(label: label,
                                  tag_type: tag_type,
                                  activity_attributes: provenance)
    end

    address.save
  end

  def self.create_provenance(provenance)
    {
      executed_at: provenance['executed_at'],
      derivations: [
        Derivation.create(entity: Source.find_or_create_by(url: provenance['url']))
      ]
    }
  end
end
