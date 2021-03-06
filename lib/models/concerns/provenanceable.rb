require 'active_support/concern'

module Provenanceable
  extend ActiveSupport::Concern

  included do
    belongs_to :activity
    accepts_nested_attributes_for :activity

    validates :activity, presence: true
    
    has_many :derived, class_name: "Derivation", as: :entity
    has_many :activities, through: :derived
    
  end


end
