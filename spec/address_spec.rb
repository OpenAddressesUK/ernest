require 'spec_helper'

describe "Address" do

  before do
    @postcode = TagType.create(label: "postcode")
    @town = TagType.create(label: "post_town")
    @locality = TagType.create(label: "locality")
    @street = TagType.create(label: "street")
    @building_no = TagType.create(label: "building_no")
  end

  it "should create a basic address" do
    address = Address.new
    address.tags << Tag.create(label: "ABC 123", tag_type: @postcode)
    address.tags << Tag.create(label: "The Shire", tag_type: @town)
    address.tags << Tag.create(label: "Hobbitton", tag_type: @locality)
    address.tags << Tag.create(label: "Hobbit Drive", tag_type: @street)
    address.tags << Tag.create(label: "3", tag_type: @building_no)

    address.save

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.post_town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.building_no.label).to eq('3')
  end

end
