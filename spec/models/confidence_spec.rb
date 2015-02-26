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

    it "can have a value" do
      # Valid
      c = Confidence.new(value: 0.85, left: @pc, right: @town)
      expect(c.value).to eq 0.85
      expect(c.valid?).to eq true
    end
    
    it "must have a value" do
      c = Confidence.new(left: @pc, right: @town)
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

end