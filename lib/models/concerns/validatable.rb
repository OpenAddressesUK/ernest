require 'active_support/concern'

module Validatable
  extend ActiveSupport::Concern

  included do

    def validate!(exists, timestamp: Time.now, attribution: nil)
      validation = Validation.create(value: exists ? 1.0 : -1.0, 
        activity_attributes: {
          attribution: attribution,
          executed_at: timestamp,
          derivations: [Derivation.new(entity: self)]
        }
      )
    end

  end


end
