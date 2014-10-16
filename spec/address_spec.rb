require 'spec_helper'

describe "Address" do

  before do
    @postcode = Tag.create(label: "postcode")
    @town = Tag.create(label: "post_town")
    @locality = Tag.create(label: "locality")
    @street = Tag.create(label: "street")
    @building_no = Tag.create(label: "building_no")
  end

  it "should create a basic address" do
    address = Address.new
    address.geo_objects << GeoObject.create(label: "ABC 123", tag: @postcode)
    address.geo_objects << GeoObject.create(label: "The Shire", tag: @town)
    address.geo_objects << GeoObject.create(label: "Hobbitton", tag: @locality)
    address.geo_objects << GeoObject.create(label: "Hobbit Drive", tag: @street)
    address.geo_objects << GeoObject.create(label: "3", tag: @building_no)

    address.save

    expect(address.geo_objects.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.post_town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.building_no.label).to eq('3')
  end

end
