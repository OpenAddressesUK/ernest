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
  
  it "supports validation with timestamp" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, timestamp: time)
  
    validation = object.derived[0].activity.validations[0]
    expect(validation.activity.executed_at).to be_within(1.seconds).of(time)
  end

  it "supports validation with attribution" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, attribution: "Made by me")
  
    validation = object.derived[0].activity.validations[0]
    expect(validation.activity.attribution).to eq "Made by me"
  end

  it "supports validation with reason" do
    pending
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, reason: "Bananas")
  
    validation = object.derived[0].activity.validations[0]
    expect(validation.activity.reason).to eq "Bananas"
  end

end
  