require 'spec_helper'

describe "TagType" do

  it "allows valid labels" do
    tag_type = TagType.new(label: 'street')

    expect(tag_type.valid?).to eq(true)
  end

  it "does not allow invalid labels" do
    tag_type = TagType.new(label: 'rubbish')

    expect(tag_type.valid?).to eq(false)
    expect(tag_type.errors.messages[:label]).to include("rubbish is not a valid label")
  end

end
