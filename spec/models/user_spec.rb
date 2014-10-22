require 'spec_helper'

describe User do

  it "Generates an API key on create" do
    user = FactoryGirl.create(:user)
    expect(user.api_key).not_to be_nil
  end

end
