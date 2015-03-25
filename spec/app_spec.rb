require 'spec_helper'

describe Ernest do

  context "creating addresses" do

    before(:each) do
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
              },
              valid_at: "2014-01-01T13:00:00Z"
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
      expect(CreateAddress).to receive(:perform_async).with(JSON.parse(@body), @user.api_key)

      post 'addresses', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

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
      expect(address.valid_at).to eq(DateTime.parse("2014-01-01T13:00:00Z"))
    end

    it "should create an address without valid_at value" do
      Sidekiq::Testing.inline!
      body = JSON.parse(@body)
      body['addresses'].first['address'].delete('valid_at')

      post 'addresses', body.to_json, { "HTTP_ACCESS_TOKEN" => @user.api_key }

      expect(Address.count).to eq(1)

      address = Address.last

      expect(address.tags.count).to eq(5)
      expect(address.postcode.label).to eq('ABC 123')
      expect(address.town.label).to eq('The Shire')
      expect(address.locality.label).to eq('Hobbitton')
      expect(address.street.label).to eq('Hobbit Drive')
      expect(address.paon.label).to eq('3')
      expect(address.valid_at).to eq(nil)
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

    it "should store provenance fields" do
      Sidekiq::Testing.inline!
      body = JSON.parse(@body)
      body['addresses'].first['provenance']['attribution'] = "Bob Fish"
      body['addresses'].first['provenance']['processing_script'] = "https://github.com/OpenAddressesUK/ernest"

      post 'addresses', body.to_json, { "HTTP_ACCESS_TOKEN" => @user.api_key }

      expect(Address.count).to eq(1)

      address = Address.last
      expect(address.activity.derivations.first.entity.input).to eq('http://www.example.com')
      expect(address.activity.derivations.first.entity.kind).to eq('url')
      expect(address.activity.attribution).to eq('Bob Fish')
      expect(address.activity.processing_script).to eq('https://github.com/OpenAddressesUK/ernest')
    end

    it "should store provenance fields for user input" do
      Sidekiq::Testing.inline!
      body = JSON.parse(@body)
      body['addresses'].first['provenance']['url'] = nil
      body['addresses'].first['provenance']['userInput'] = "Bob Loblaw's Law Blog"

      post 'addresses', body.to_json, { "HTTP_ACCESS_TOKEN" => @user.api_key }

      expect(Address.count).to eq(1)

      address = Address.last
      expect(address.activity.derivations.first.entity.input).to eq("Bob Loblaw's Law Blog")
      expect(address.activity.derivations.first.entity.kind).to eq('userInput')
    end

    it "should apply a user" do
      Sidekiq::Testing.inline!
      post 'addresses', @body, { "HTTP_ACCESS_TOKEN" => @user.api_key }

      expect(Address.last.user).to eq(@user)
    end

  end

  context "listing addresses" do

    it "should return a list of addresses" do
      20.times do
        FactoryGirl.create(:address)
      end

      get 'addresses'
      response = JSON.parse last_response.body

      expect(last_response.header["Content-Type"]).to eq("application/json")
      expect(response['addresses'].count).to eq 20

      expect(response['addresses'].first).to include(
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

      expect(response['addresses'].last).to include(
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

    it "should include static provenance information for old addresses" do
      Timecop.freeze("2014-01-01T11:00:00.000Z")
      FactoryGirl.create(:address)

      get 'addresses'
      response = JSON.parse last_response.body

      expect(response['addresses'].last["provenance"]["activity"]["processing_script"]).to eq("https://github.com/OpenAddressesUK/common-ETL/blob/efcd9970fc63c12b2f1aef410f87c2dcb4849aa3/CH_Bulk_Extractor.py")
      expect(response['addresses'].last["provenance"]["activity"]["derived_from"].length).to be(4)

      Timecop.return
    end

    it "should generate correct provenance for new stuff" do
      Timecop.freeze("2015-02-02T11:00:00.000Z")

      entity = FactoryGirl.create(:source, kind: "url", input: "http://foo.bar/baz", activity: FactoryGirl.create(:activity, processing_script: "http://foo.bar"))
      derivation = FactoryGirl.create(:derivation, entity: entity)

      FactoryGirl.create(:address, activity: FactoryGirl.create(:activity, derivations: [derivation]))

      get 'addresses'
      response = JSON.parse last_response.body

      expect(response['addresses'].last["provenance"]["activity"]["derived_from"].count).to eq(1)
      expect(response['addresses'].last["provenance"]["activity"]["derived_from"].first["type"]).to eq("url")
      expect(response['addresses'].last["provenance"]["activity"]["derived_from"].first["processing_script"]).to eq("http://foo.bar")
      expect(response['addresses'].last["provenance"]["activity"]["derived_from"].first["urls"].first).to eq("http://foo.bar/baz")

      Timecop.return
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

    it "should return a list of addresses that have been updated since a certain date" do
      Timecop.freeze(DateTime.new(2013,1,1))

      5.times do
        FactoryGirl.create(:address)
      end

      Timecop.return

      date = DateTime.now

      5.times do
        FactoryGirl.create(:address)
      end

      get 'addresses', { updated_since: date.strftime("%Y-%m-%dT%H:%M:%S%z") }

      response = JSON.parse last_response.body

      expect(last_response.header["Content-Type"]).to eq("application/json")
      expect(response['addresses'].count).to eq 5
    end

    it "returns 400 if date format is incorrect" do
      get 'addresses', { updated_since: "Ed Balls" }

      expect(last_response.status).to eq(400)
    end

  end

  context "confidence as a service" do

    before :each do
      Address.skip_callback(:create, :after, :generate_score)

      35.times do |n|
        FactoryGirl.create(:address, tags: [
          FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
          FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
          FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
          FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
          FactoryGirl.create(:tag, label: n, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
        ])
      end

      @body = {
        paon:  "3",
        street: "Hobbit Drive",
        locality: "Hobbitton",
        town: "The Shire",
        postcode: "SW1A 1AA",
      }
    end

    it "generates confidence" do
      post 'confidence', @body.to_json, {}

      response = JSON.parse last_response.body

      expect(last_response.status).to eq(200)
      expect(last_response.header["Content-Type"]).to eq("application/json")
      expect(response['confidence']).to be_within(0.0001).of(505.3389914223)
    end

    it "heurisically adjusts" do
      @body['valid_at'] = DateTime.now - 15.years

      post 'confidence', @body.to_json, {}

      response = JSON.parse last_response.body

      expect(response['confidence']).to be_within(0.1).of(505.3389914223 / 2)
    end

    it "returns the original address" do
      post 'confidence', @body.to_json, {}

      response = JSON.parse last_response.body

      expect(response['address']).to eq(@body)
    end

  end

end
