require 'spec_helper'

shared_examples_for "Provenanceable" do

  it "should create an associated activity" do
    object = FactoryGirl.create(described_class)

    expect(object.activity).not_to be_nil
  end

  it "allows the executed_at time to be set" do
    time = DateTime.now
    source = FactoryGirl.create(described_class, activity_attributes: { executed_at: time })

    expect(source.activity.executed_at).to eq(time)
  end

  it "allows derivations to be set" do
    source = FactoryGirl.create(described_class, activity_attributes: { derivations: [
        FactoryGirl.create(:derivation)
      ] })

    expect(source.activity.derivations.count).to eq(1)
  end

end
