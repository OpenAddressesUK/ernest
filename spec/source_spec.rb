require 'spec_helper'

describe "Source" do

  it "creates an activity on save" do
    source = FactoryGirl.create(:source)

    expect(source.activity).not_to be_nil
  end

  it "allows the executed_at time to be set" do
    time = DateTime.now
    source = FactoryGirl.create(:source, activity_attributes: { executed_at: time })

    expect(source.activity.executed_at).to eq(time)
  end

end
