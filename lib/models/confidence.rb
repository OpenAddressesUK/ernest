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
    # Work that shit out
    send(:"calculate_for_#{left.tag_type.label}_and_#{right.tag_type.label}", left, right)
  end

  def calculate_for_postcode_and_town(postcode, town)
    calculate_for_town_and_postcode(town, postcode)
  end

  def calculate_for_town_and_postcode(town, postcode)
    postcodes = get_postcodes_in_sector(postcode)
    addresses = addresses_from_postcodes(postcodes)
    town_count = town_count_from_addresses(addresses, town)
    pc_count = postcode_count(postcodes)
    confidence(town_count, pc_count)
  end

  def calculate_for_postcode_and_street(postcode, street)
    calculate_for_street_and_postcode(street, postcode)
  end

  def calculate_for_street_and_postcode(street, postcode)
    postcodes = get_postcodes(postcode)
    addresses = addresses_from_postcodes(postcodes)
    street_count = street_count_from_addresses(addresses, street)
    pc_count = postcode_count(postcodes)
    confidence(street_count, pc_count)
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

  # Split out so we can stub and test easily

  def get_postcodes(postcode)
    postcodes = Tag.where(label: postcode.label)
  end

  def get_postcodes_in_sector(postcode)
    pc = UKPostcode.parse(postcode.label)
    sector = "#{pc.outcode} #{pc.sector}"
    postcodes = Tag.where("label LIKE ?", "#{sector}%")
  end

  def street_count_from_addresses(addresses, street)
    addresses.select { |a| a.street.label == street.label }.count
  end

  def town_count_from_addresses(addresses, town)
    addresses.select { |a| a.town.label == town.label }.count
  end

  def addresses_from_postcodes(postcodes)
    postcodes.map { |p| p.addresses }.flatten
  end

  def postcode_count(postcodes)
    postcodes.count
  end

end
