class Activity < ActiveRecord::Base
  
  # Things that this activity generated
  has_many :addresses
  has_many :tags
  has_many :sources
  has_many :validations
  
  # Things that this activity USED
  has_many :derivations
  
end