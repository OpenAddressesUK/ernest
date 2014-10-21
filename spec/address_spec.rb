require 'spec_helper'

describe "Address" do

  it "should create a basic address" do
    address = FactoryGirl.create(:address)

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.post_town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.building_no.label).to eq('3')
  end

  it "should create an associated activity" do
    address = FactoryGirl.create(:address)

    expect(address.activity).not_to be_nil
  end

end
