class Derivation < ActiveRecord::Base
  
  belongs_to :entity, polymorphic: true
  belongs_to :activity
  
end