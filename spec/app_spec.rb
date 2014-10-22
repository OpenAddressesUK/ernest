require 'spec_helper'

describe Ernest do

  before(:all) do
    @user = FactoryGirl.create(:user)
    @body = {
      address: {
        building_no: "3",
        street: "Hobbit Drive",
        locality: "Hobbitton",
        post_town: "The Shire",
        postcode: "ABC 123"
      },
      provenance: {
        executed_at: "2014-01-01T13:00:00Z",
        url: "http://www.example.com"
      }
    }.to_json
  end

  it "should return 401 if the API key is incorrect" do
    post 'address', nil, { "HTTP_ACCESS_TOKEN" => 'thisisobviouslyfake' }
    expect(last_response.status).to eq(401)
  end

  it "should queue a CreateAddress job" do
    post 'address', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(CreateAddress).to have_queued(JSON.parse(@body), @user.id)
    expect(last_response.status).to eq(202)
  end

  it "should create an address" do
    with_resque do
      post 'address', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }
    end

    expect(Address.count).to eq(1)

    address = Address.last

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.post_town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.building_no.label).to eq('3')
  end

  it "should apply a user" do
    with_resque do
      post 'address', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }
    end

    expect(Address.last.user).to eq(@user)
  end

end
