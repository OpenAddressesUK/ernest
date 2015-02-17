require 'spec_helper'

describe Ernest do
  before :each do
    @user = FactoryGirl.create :user
    @address = FactoryGirl.create :address
  end

  it "allows validation of an existing address" do
    post "addresses/#{@address.id}/validations", '{ "exists": true }', { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(@address.derived[0].activity.validations[0].value).to eq 1.0
  end

  it "allows rejection of an existing address" do
    post "addresses/#{@address.id}/validations", '{ "exists": false }', { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(@address.derived[0].activity.validations[0].value).to eq -1.0
  end

  it "accepts a timestamp with a validation" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "timestamp": "2015-01-21T16:18:32+00:00" }', { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(@address.derived[0].activity.executed_at).to eq '2015-01-21T16:18:32+00:00'
  end

  it "accepts an attribution with a validation" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "attribution": "Rotated Owl" }', { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(@address.derived[0].activity.attribution).to eq 'Rotated Owl'
  end

  it "accepts a reason with an attribution" do
    post "addresses/#{@address.id}/validations", '{ "exists": true, "reason": "For Science" }', { "HTTP_ACCESS_TOKEN" => @user.api_key }

    expect(@address.derived[0].activity.validations[0].reason).to eq 'For Science'
  end
end