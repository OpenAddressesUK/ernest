require 'spec_helper'

describe Confidence do

  context "testing the basics" do

    before do
      # Make a pair of tags
      pc_type = FactoryGirl.create(:tag_type, label: "postcode")
      town_type = FactoryGirl.create(:tag_type, label: "town")
      @pc = FactoryGirl.create(:tag, label: "XX1 1XX", tag_type: pc_type)
      @town = FactoryGirl.create(:tag, label: "Fooville", tag_type: town_type)
    end

    it "can have a manually-set value" do
      # Valid
      c = Confidence.new(value: 0.85, left: @pc, right: @town)
      expect(c.value).to eq 0.85
      expect(c.valid?).to eq true
    end

    it "must have a value" do
      c = Confidence.new(left: @pc, right: @town)
      c.value = nil
      expect(c.valid?).to eq false
      expect(c.errors[:value]).to eq ["can't be blank"]
    end

    it "can relate the two together" do
      # Relate them together
      c = Confidence.new(value: 0.85, left: @pc, right: @town)
      # Check the relation
      expect(c.left).to eq @pc
      expect(c.right).to eq @town
      expect(c.valid?).to eq true
    end

    it "must have both sides" do
      # Relate them together
      c = Confidence.new(value: 0.85, left: nil, right: nil)
      # Check the relation
      expect(c.valid?).to eq false
      expect(c.errors[:left]).to eq ["can't be blank"]
      expect(c.errors[:right]).to eq ["can't be blank"]
    end

  end

  context "creating confidence measures" do

    before do
      # Make a pair of tags
      pc_type = FactoryGirl.create(:tag_type, label: "postcode")
      town_type = FactoryGirl.create(:tag_type, label: "town")
      @pc = FactoryGirl.create(:tag, label: "XX1 1XX", tag_type: pc_type)
      @town = FactoryGirl.create(:tag, label: "Fooville", tag_type: town_type)
    end

    it "should be able to create a confidence measure given a pair of tags" do
      # Create the confidence measure with just the tags
      c = Confidence.new(left: @pc, right: @town)
      expect(c.value).to be_present
      expect(c.valid?).to eq true
      # Confidence should have generated a value for us
      expect(c.value).to be_present
    end

    it "should generate a proper confidence measure" do
      35.times do |n|
        FactoryGirl.create(:address, tags: [
          FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
          FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
          FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
          FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
          FactoryGirl.create(:tag, label: n, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
        ])
      end

      pc = Tag.where(label: "SW1A 1AA").first
      town = Tag.where(label: "The Shire").first
      c = Confidence.new(left: pc, right: town)
      expect(c.value).to be_within(0.0001).of(0.8284)
    end

  end

end
