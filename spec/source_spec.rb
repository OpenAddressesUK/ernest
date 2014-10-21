require 'spec_helper'

describe "Source" do

  it "creates an activity on save" do
    source = Source.create(url: "http://www.example.com")

    expect(source.activity).not_to be_nil
  end

end
