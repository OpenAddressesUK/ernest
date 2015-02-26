require 'statsample'
require 'uk_postcode'

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
    # number of times this town appears in a postcode sector
    if left.tag_type.label == "town" && right.tag_type.label == "postcode"
      calculate_for_town_and_postcode(left, right)
    elsif left.tag_type.label == "postcode" && right.tag_type.label == "town"
      calculate_for_town_and_postcode(right, left)
    end
  end

  def calculate_for_town_and_postcode(town, postcode)
    pc = UKPostcode.parse(postcode.label)
    sector = "#{pc.outcode} #{pc.sector}"
    postcodes = Tag.where("label LIKE ?", "#{sector}%")
    addresses = postcodes.map { |p| p.addresses }.flatten
    town_count = addresses.select { |a| a.town.label == town.label }.count
    pc_count = postcodes.count
    confidence(town_count, pc_count)
  end

  def confidence(number, total)
    pc = number.to_f / total.to_f
    standard_error = Math.sqrt(0.25/total.to_f)
    tval = Statsample::Test.t_critical(0.95,total.to_f)
    margin = standard_error * tval
    if pc > 0.0
      self.value = [1-(margin/pc),0.0].max
    else
      self.value = 0.0
    end
  end


end
