require 'spec_helper'

shared_examples_for "Validatable" do

  it "supports positive validation" do
    object = FactoryGirl.create(described_class)

    object.validate!(true)

    expect(object.derived[0].activity.validations).not_to be_empty
    expect(object.derived[0].activity.validations[0].value).to eq 1.0
  end

  it "supports negative validation" do
    object = FactoryGirl.create(described_class)

    object.validate!(false)

    expect(object.derived[0].activity.validations).not_to be_empty
    expect(object.derived[0].activity.validations[0].value).to eq -1.0
  end
  
  it "supports validation with optional fields" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, timestamp: time) # attribution: "Made by me", reason: "Bananas", 
  
    validation = object.derived[0].activity.validations[0]
    expect(validation.activity.executed_at).to be_within(1.seconds).of(time)
  end

end
  