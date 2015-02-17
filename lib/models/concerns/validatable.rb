require 'active_support/concern'

module Validatable
  extend ActiveSupport::Concern

  included do

    def validate!(exists)
      validation = Validation.create(value: exists ? 1.0 : -1.0, activity_attributes: { 
        derivations: [Derivation.new(entity: self)]
      })
    end

  end


end
