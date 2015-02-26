class Confidence < ActiveRecord::Base
  
  belongs_to :left, :class_name => 'Tag'
  belongs_to :right, :class_name => 'Tag'

  validates :value, presence: true
  validates :left,  presence: true
  validates :right, presence: true

end