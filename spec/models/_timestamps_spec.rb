require 'spec_helper'

shared_examples_for "Timestamps" do

  it "should add timestamps" do
    address = FactoryGirl.create(described_class)

    expect(address.created_at.class).to eq(Time)
    expect(address.updated_at.class).to eq(Time)
  end

end
