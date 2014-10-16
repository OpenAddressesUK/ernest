require 'spec_helper'

describe "Tag" do

  it "allows valid labels" do
    tag = Tag.new(label: 'street')

    expect(tag.valid?).to eq(true)
  end

  it "does not allow invalid labels" do
    tag = Tag.new(label: 'rubbish')

    expect(tag.valid?).to eq(false)
    expect(tag.errors.messages[:label]).to include("rubbish is not a valid label")
  end

end
