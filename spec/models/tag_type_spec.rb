require 'spec_helper'

describe TagType do

  it "allows valid labels" do
    tag_type = FactoryGirl.create(:tag_type)
    expect(tag_type.valid?).to eq(true)
  end

  it "does not allow invalid labels" do
    tag_type = FactoryGirl.build(:tag_type, label: 'rubbish')

    expect(tag_type.valid?).to eq(false)
    expect(tag_type.errors.messages[:label]).to include("rubbish is not a valid label")
  end

end
