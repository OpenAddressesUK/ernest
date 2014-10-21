require 'spec_helper'

describe "Tag" do

  it "should allow creation without geo objects" do
    tag = FactoryGirl.create(:tag)

    expect(tag.valid?).to eq(true)
    expect(tag.point.to_s).to eq("POINT (0.0 0.0)")
    expect(tag.line.to_s).to eq("LINESTRING (0.0 0.0, 0.0 10.0)")
    expect(tag.area.to_s).to eq("POLYGON ((0.0 1.0, 2.0 1.0, 2.0 2.0, 1.0 2.0, 0.0 1.0))")
  end

  it "should allow overriding of defaults" do
    tag = FactoryGirl.create(:tag, point: "POINT (5.0 10.0)", line: "LINESTRING (1.0 2.0, 10.0 7.0)", area: "POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")

    expect(tag.valid?).to eq(true)
    expect(tag.point.to_s).to eq("POINT (5.0 10.0)")
    expect(tag.line.to_s).to eq("LINESTRING (1.0 2.0, 10.0 7.0)")
    expect(tag.area.to_s).to eq("POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")
  end

  it "should create an associated activity" do
    tag = FactoryGirl.create(:tag)

    expect(tag.activity).not_to be_nil
  end

end
