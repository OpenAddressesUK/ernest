require 'spec_helper'

describe Confidence do

  context "testing the basics" do

    before :all do
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

    it "should be able to create a confidence measure given a pair of tags" do
      # Make a pair of tags
      pc_type = FactoryGirl.create(:tag_type, label: "postcode")
      town_type = FactoryGirl.create(:tag_type, label: "town")
      pc = FactoryGirl.create(:tag, label: "XX1 1XX", tag_type: pc_type)
      town = FactoryGirl.create(:tag, label: "Fooville", tag_type: town_type)
      # Create the confidence measure with just the tags
      c = Confidence.new(left: pc, right: town)
      expect(c.value).to be_present
      expect(c.valid?).to eq true
      # Confidence should have generated a value for us
      expect(c.value).to be_present
    end

    context "with a load of data" do
      before :all do
        35.times do |n|
          FactoryGirl.create(:address, tags: [
            FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
            FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
            FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
            FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
            FactoryGirl.create(:tag, label: n, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
          ])
        end
      end

      it "should calculate confidence between postcodes and towns" do
        pc = Tag.where(label: "SW1A 1AA").last
        town = Tag.where(label: "The Shire").last
        c = Confidence.new(left: pc, right: town)
        expect(c.value).to be_within(0.0001).of(0.8284)
      end

      it "should calculate confidence between towns and postcodes" do
        pc = Tag.where(label: "SW1A 1AA").last
        town = Tag.where(label: "The Shire").last
        c = Confidence.new(left: town, right: pc)
        expect(c.value).to be_within(0.0001).of(0.8284)
      end

      it "should calculate confidence between postcodes and streets" do
        pc = Tag.where(label: "SW1A 1AA").last
        street = Tag.where(label: "Hobbit Drive").last
        c = Confidence.new(left: pc, right: street)
        expect(c.value).to be_within(0.0001).of(0.8284)
      end

      it "should calculate confidence between streets and postcodes" do
        pc = Tag.where(label: "SW1A 1AA").last
        street = Tag.where(label: "Hobbit Drive").last
        c = Confidence.new(left: street, right: pc)
        expect(c.value).to be_within(0.0001).of(0.8284)
      end

    end

  end

  context "with stubbed data" do

    before :all do
      # Make a pair of tags
      pc_type = FactoryGirl.create(:tag_type, label: "postcode")
      town_type = FactoryGirl.create(:tag_type, label: "town")
      @pc = FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: pc_type)
      @town = FactoryGirl.create(:tag, label: "Fooville", tag_type: town_type)
    end

    [
      {matching: 470, total: 473, confidence: 0.9545},
      {matching: 454,	total: 454,	confidence: 0.9539},
      {matching: 403,	total: 407,	confidence: 0.9508},
      {matching: 4,	  total: 407,	confidence: 0.000},
      {matching: 87,	total: 87,	confidence: 0.8935},
      {matching: 560,	total: 563,	confidence: 0.9584},
      {matching: 3,	  total: 563,	confidence: 0.000},
      {matching: 333,	total: 335,	confidence: 0.9459},
      {matching: 1,	  total: 335,	confidence: 0.000},
      {matching: 1,	  total: 335,	confidence: 0.000},
      {matching: 101,	total: 103,	confidence: 0.9004},
      {matching: 2,	  total: 103,	confidence: 0.000},
      {matching: 129,	total: 129,	confidence: 0.9129},
      {matching: 34,	total: 34,	confidence: 0.8257},
      {matching: 60,	total: 60,	confidence: 0.8709},
      {matching: 15,	total: 15,	confidence: 0.7248},
      {matching: 35,	total: 35,	confidence: 0.8284},
      {matching: 76,	total: 76,	confidence: 0.8858},
      {matching: 13,	total: 13,	confidence: 0.7004},
      {matching: 62,	total: 62,	confidence: 0.8731},
      {matching: 49,	total: 49,	confidence: 0.8565},
      {matching: 78,	total: 78,	confidence: 0.8873},
      {matching: 686,	total: 689,	confidence: 0.9624},
      {matching: 3,	  total: 689,	confidence: 0.000},
      {matching: 25,	total: 25,	confidence: 0.7940},
      {matching: 83,	total: 91,	confidence: 0.8859},
      {matching: 1,	  total: 91,	confidence: 0.000},
      {matching: 7,	  total: 91,	confidence: 0.000},
      {matching: 22,	total: 25,	confidence: 0.7660},
    ].each do |data|

      it "should get confidence #{data[:confidence]} when #{data[:matching]} out of #{data[:total]} match" do
        expect_any_instance_of(Confidence).to receive(:town_count_from_addresses).and_return(data[:matching])
        expect_any_instance_of(Confidence).to receive(:postcode_count).and_return(data[:total])
        c = Confidence.new(left: @town, right: @pc)
        expect(c.value).to be_within(0.0001).of(data[:confidence])
      end

    end

  end

end
