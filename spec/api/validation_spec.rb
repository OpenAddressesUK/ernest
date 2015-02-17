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
end
