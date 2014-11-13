require 'spec_helper'

describe CreateAddress do

  before(:all) do
    @user = FactoryGirl.create(:user)
    @body = {
      addresses: [
        {
          address: {
            paon: {
              name: "3"
            },
            street: {
              name: "Hobbit Drive"
            },
            locality: {
              name: "Hobbitton"
            },
            town: {
              name: "The Shire"
            },
            postcode: {
              name: "ABC 123"
            }
          },
          provenance: {
            executed_at: "2014-01-01T13:00:00Z",
            url: "http://www.example.com"
          }
        }
      ]
    }.to_json
  end

  it "should create an address" do
    worker = CreateAddress.new
    worker.perform(JSON.parse(@body), @user.id)

    expect(Address.count).to eq(1)

    address = Address.last

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.paon.label).to eq('3')
  end

  it "should create an address with geodata" do
    worker = CreateAddress.new
    body = JSON.parse(@body)
    body['addresses'].first['address']['street']['geometry'] = {
      "type" => "Point",
      "coordinates" => [
        179645, 529090
      ]
    }

    worker.perform(body, @user.id)

    expect(Address.count).to eq(1)

    address = Address.last

    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.street.point.to_s).to eq("POINT (179645.0 529090.0)")
    expect(address.town.point.to_s).to eq("POINT (0.0 0.0)")
  end

  it "should create multiple addresses" do
    body = {
      addresses: [
        {
          address: {
            paon: {
              name: "3"
            },
            street: {
              name: "Hobbit Drive"
            },
            locality: {
              name: "Hobbitton"
            },
            town: {
              name: "The Shire"
            },
            postcode: {
              name: "ABC 123"
            }
          },
          provenance: {
            executed_at: "2014-01-01T13:00:00Z",
            url: "http://www.example.com"
          }
        },
        {
          address: {
            paon: {
              name: "3"
            },
            street: {
              name: "Hobbit Drive"
            },
            locality: {
              name: "Hobbitton"
            },
            town: {
              name: "The Shire"
            },
            postcode: {
              name: "ABC 123"
            }
          },
          provenance: {
            executed_at: "2014-01-01T13:00:00Z",
            url: "http://www.example.com"
          }
        },
        {
          address: {
            paon: {
              name: "3"
            },
            street: {
              name: "Hobbit Drive"
            },
            locality: {
              name: "Hobbitton"
            },
            town: {
              name: "The Shire"
            },
            postcode: {
              name: "ABC 123"
            }
          },
          provenance: {
            executed_at: "2014-01-01T13:00:00Z",
            url: "http://www.example.com"
          }
        }
      ]
    }.to_json

    worker = CreateAddress.new

    worker.perform(JSON.parse(body), @user.id)

    expect(Address.count).to eq(3)
  end

  it "should apply a user" do
    worker = CreateAddress.new
    worker.perform(JSON.parse(@body), @user.id)

    expect(Address.last.user).to eq(@user)
  end

end
