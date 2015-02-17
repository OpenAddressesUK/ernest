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

  it "allows access to derived entities" do
    entity = FactoryGirl.create(described_class, activity_attributes: { derivations: [
        FactoryGirl.create(:derivation)
      ] })    
    
    source = entity.activity.derivations[0].entity
    expect(source).to be_present
    expect(source.class).to eq Source

    expect(source.activities[0].send(described_class.name.downcase.pluralize.to_sym)[0]).to eq entity
    
  end

end
