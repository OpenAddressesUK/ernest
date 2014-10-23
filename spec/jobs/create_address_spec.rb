require 'spec_helper'

describe CreateAddress do

  before(:all) do
    @user = FactoryGirl.create(:user)
    @body = {
      address: {
        paon: "3",
        street: "Hobbit Drive",
        locality: "Hobbitton",
        town: "The Shire",
        postcode: "ABC 123"
      },
      provenance: {
        executed_at: "2014-01-01T13:00:00Z",
        url: "http://www.example.com"
      }
    }.to_json
  end

  it "should create an address" do
    CreateAddress.perform(JSON.parse(@body), @user.id)

    expect(Address.count).to eq(1)

    address = Address.last

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.paon.label).to eq('3')
  end

  it "should apply a user" do
    CreateAddress.perform(JSON.parse(@body), @user.id)

    expect(Address.last.user).to eq(@user)
  end

end
