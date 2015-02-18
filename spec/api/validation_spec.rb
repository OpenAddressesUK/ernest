require 'spec_helper'

describe Ernest do
  before :each do
    @address = FactoryGirl.create :address
  end

  it "allows cross-origin requests" do
    post "addresses/#{@address.id}/validations", '{ "exists": true }', {'HTTP_ORIGIN' => 'http://example.com'}

    expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://example.com'
  end

  it "allows validation of an existing address" do
    post "addresses/#{@address.id}/validations", '{ "exists": true }'

    expect(@address.activities[0].validations[0].value).to eq 1.0
  end

  it "allows rejection of an existing address" do
    post "addresses/#{@address.id}/validations", '{ "exists": false }'

    expect(@address.activities[0].validations[0].value).to eq -1.0
  end

  it "accepts a timestamp with a validation" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "timestamp": "2015-01-21T16:18:32+00:00" }'

    expect(@address.activities[0].executed_at).to eq '2015-01-21T16:18:32+00:00'
  end

  it "accepts an attribution with a validation" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "attribution": "Rotated Owl" }'

    expect(@address.activities[0].attribution).to eq 'Rotated Owl'
  end

  it "accepts a reason with an attribution" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "reason": "For Science" }'

    expect(@address.activities[0].validations[0].reason).to eq 'For Science'
  end
end
