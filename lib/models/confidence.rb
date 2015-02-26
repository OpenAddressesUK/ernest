class Confidence < ActiveRecord::Base
  
  belongs_to :left, :class_name => 'Tag'
  belongs_to :right, :class_name => 'Tag'

  validates :value, presence: true
  validates :left,  presence: true
  validates :right, presence: true

  after_initialize :calculate_value

  private
  
  def calculate_value
    # If we already have a value, EJECT
    return if value
    # MAGIC
    self.value = 0.0
  end

end