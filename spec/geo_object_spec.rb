require 'spec_helper'

describe "GeoObject" do

  it "should allow creation without geo objects" do
    geo_object = GeoObject.create(label: "Bigtown")

    expect(geo_object.valid?).to eq(true)
    expect(geo_object.point.to_s).to eq("POINT (0.0 0.0)")
    expect(geo_object.line.to_s).to eq("LINESTRING (0.0 0.0, 0.0 10.0)")
    expect(geo_object.area.to_s).to eq("POLYGON ((0.0 1.0, 2.0 1.0, 2.0 2.0, 1.0 2.0, 0.0 1.0))")
  end

  it "should allow nesting" do
    town = GeoObject.create(label: "Big Town" )
    postcode = GeoObject.create(label: "ABC 123")

    town.contained_geo_objects << postcode
    town.save

    expect(town.contains.to_a.count).to eq(1)
    expect(town.contains.first.label).to eq("ABC 123")

    expect(postcode.contained_by.to_a.count).to eq(1)
    expect(postcode.contained_by.first.label).to eq("Big Town")
  end

  it "should allow overriding of defaults" do
    geo_object = GeoObject.create(label: "Bigtown", point: "POINT (5.0 10.0)", line: "LINESTRING (1.0 2.0, 10.0 7.0)", area: "POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")

    expect(geo_object.valid?).to eq(true)
    expect(geo_object.point.to_s).to eq("POINT (5.0 10.0)")
    expect(geo_object.line.to_s).to eq("LINESTRING (1.0 2.0, 10.0 7.0)")
    expect(geo_object.area.to_s).to eq("POLYGON ((1.0 2.0, 1.0 4.0, 3.0 4.0, 1.0 2.0))")
  end

end
