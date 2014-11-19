require 'spec_helper'

describe Ernest do

  before(:all) do
    @user = FactoryGirl.create(:user)
    ENV['ERNEST_ALLOWED_KEYS'] = @user.api_key
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

  it "should return 401 if the API key is incorrect" do
    post 'addresses', nil, { "HTTP_ACCESS_TOKEN" => 'thisisobviouslyfake' }
    expect(last_response.status).to eq(401)
  end

  it "should return 400 if the body is blank" do
    post 'addresses', "", { "HTTP_ACCESS_TOKEN" => @user.api_key }
    expect(last_response.status).to eq(400)
  end

  it "should return 400 if the json is bad" do
    body = JSON.parse(@body)
    post 'addresses', body[0..-4], { "HTTP_ACCESS_TOKEN" => @user.api_key }
    expect(last_response.status).to eq(400)
  end

  it "should queue a CreateAddress job" do
    post 'addresses', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(CreateAddress).to have_enqueued_job(JSON.parse(@body), @user.api_key)
    expect(last_response.status).to eq(202)
  end

  it "should create an address" do
    Sidekiq::Testing.inline!
    post 'addresses', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

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
    Sidekiq::Testing.inline!
    body = JSON.parse(@body)
    body['addresses'].first['address']['street']['geometry'] = {
      "type" => "Point",
      "coordinates" => [
        179645, 529090
      ]
    }
    post 'addresses', body.to_json, { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(Address.count).to eq(1)

    address = Address.last

    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.street.point.to_s).to eq("POINT (179645.0 529090.0)")
  end

  it "should apply a user" do
    Sidekiq::Testing.inline!
    post 'addresses', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(Address.last.user).to eq(@user)
  end

  it "should return a list of addresses" do
    20.times do
      FactoryGirl.create(:address)
    end

    get 'addresses'
    response = JSON.parse last_response.body

    expect(last_response.header["Content-Type"]).to eq("application/json")
    expect(response['addresses'].count).to eq 20

    expect(response['addresses'].first).to eq(
      {
        "saon"=>{
          "name"=>nil
        },
        "paon"=>{
          "name"=>"3"
        },
        "street"=>{
          "name"=>"Hobbit Drive"
        },
        "locality"=>{
          "name"=>"Hobbitton"
        },
        "town"=>{
          "name"=>"The Shire",
          "geometry"=>{
            "type"=>"Point",
            "coordinates"=>[411754.0, 309250.0]
          }
        },
        "postcode"=>{
          "name"=>"ABC 123"
        },
        "country"=>{
          "name"=>nil
        }
      }
    )

    expect(response['addresses'].last).to eq(
      {
        "saon"=>{
          "name"=>nil
        },
        "paon"=>{
          "name"=>"3"
        },
        "street"=>{
          "name"=>"Hobbit Drive"
        },
        "locality"=>{
          "name"=>"Hobbitton"
        },
        "town"=>{
          "name"=>"The Shire",
          "geometry"=>{
            "type"=>"Point",
            "coordinates"=>[411754.0, 309250.0]
          }
        },
        "postcode"=>{
          "name"=>"ABC 123"
        },
        "country"=>{
          "name"=>nil
        }
      }
    )

  end

  it "should paginate correctly" do
    50.times do
      FactoryGirl.create(:address)
    end

    get 'addresses', { page: 1 }
    response = JSON.parse last_response.body
    expect(response['addresses'].count).to eq 25
  end

  it "shows correct paginatation information without a page number" do
    55.times do
      FactoryGirl.create(:address)
    end

    get 'addresses'
    response = JSON.parse last_response.body
    expect(response['pages']).to eq 3
    expect(response['total']).to eq 55
    expect(response['current_page']).to eq 1
  end

  it "shows correct paginatation information with a page number" do
    55.times do
      FactoryGirl.create(:address)
    end

    get 'addresses', {page: 2}
    response = JSON.parse last_response.body
    expect(response['pages']).to eq 3
    expect(response['total']).to eq 55
    expect(response['current_page']).to eq 2
  end

end
