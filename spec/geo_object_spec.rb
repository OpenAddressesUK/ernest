require 'spec_helper'

describe "GeoObject" do

  it "should allow creation without geo objects" do
    geo_object = GeoObject.create(label: "Bigtown")

    expect(geo_object.valid?).to eq(true)
    expect(geo_object.point.to_s).to eq("POINT (0.0 0.0)")
    expect(geo_object.line.to_s).to eq("LINESTRING (0.0 0.0, 0.0 10.0)")
    expect(geo_object.area.to_s).to eq("POLYGON ((0.0 1.0, 2.0 1.0, 2.0 2.0, 1.0 2.0, 0.0 1.0))")
  end

  it "should allow dependent geo_objects" do
    geo_object = GeoObject.create(label: "Little Street" )
    geo_object.dependents << GeoObject.create(label: "Big Street")
    geo_object.save

    expect(geo_object.dependents.count).to eq(1)
    expect(geo_object.dependents.first.label).to eq("Big Street")
  end

  it "should allow overriding of defaults" do
    geo_object = GeoObject.create(label: "Bigtown", point: "POINT (5.0 10.0)", line: "LINESTRING (1.0 2.0, 10.0 7.0)", area: "POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")

    expect(geo_object.valid?).to eq(true)
    expect(geo_object.point.to_s).to eq("POINT (5.0 10.0)")
    expect(geo_object.line.to_s).to eq("LINESTRING (1.0 2.0, 10.0 7.0)")
    expect(geo_object.area.to_s).to eq("POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")
  end

end
