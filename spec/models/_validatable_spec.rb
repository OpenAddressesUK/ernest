require 'spec_helper'

shared_examples_for "Validatable" do

  it "supports positive validation" do
    object = FactoryGirl.create(described_class)

    object.validate!(true)

    expect(object.activities[0].validations).not_to be_empty
    expect(object.activities[0].validations[0].value).to eq 1.0
  end

  it "supports negative validation" do
    object = FactoryGirl.create(described_class)

    object.validate!(false)

    expect(object.activities[0].validations).not_to be_empty
    expect(object.activities[0].validations[0].value).to eq -1.0
  end
  
  it "supports validation with timestamp" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, timestamp: time)
  
    validation = object.activities[0].validations[0]
    expect(validation.activity.executed_at).to be_within(1.seconds).of(time)
  end

  it "supports validation with attribution" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, attribution: "James Smith <james@example.com>")
  
    validation = object.activities[0].validations[0]
    expect(validation.activity.attribution).to eq "James Smith <james@example.com>"
  end

  it "supports validation with reason" do
    object = FactoryGirl.create(described_class)
    time = 2.days.ago.to_time
  
    object.validate!(true, reason: "It's been demolished")
  
    validation = object.activities[0].validations[0]
    expect(validation.reason).to eq "It's been demolished"
  end

end
  