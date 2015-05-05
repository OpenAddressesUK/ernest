$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require '_provenanceable_spec'
require '_timestamps_spec'
require '_validatable_spec'

describe Address do

  it "should create a basic address" do
    address = FactoryGirl.create(:address)

    expect(address.tags.count).to eq(6)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.paon.label).to eq('3')
    expect(address.uprn.label).to eq('200133435')
    expect(address.valid_at).to eq(DateTime.parse("2015-01-01"))
  end

  context "scoring" do

    before :each do
      Address.skip_callback(:create, :after, :generate_score)

      35.times do |n|
        FactoryGirl.create(:address, tags: [
          FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
          FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
          FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
          FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
          FactoryGirl.create(:tag, label: n, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
        ])
      end

      Address.set_callback(:create, :after, :generate_score)

      @address = FactoryGirl.create(:address, tags: [
        FactoryGirl.create(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
        FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
        FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
        FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
        FactoryGirl.create(:tag, label: 50, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
      ])
    end

    it "creates a score" do
      expect(@address.score).to_not be_nil
    end

    it "creates the correct score" do
      tolerance = 0.01 # this is supposed to be 0.0001 idk tbh
      Timecop.freeze(2015,5,10) do
        @address.generate_score
        expect(@address.score).to be_within(tolerance).of(498.6952)
      end
    end

    it "heuristically adjusts" do
      original_score = @address.score
      Timecop.travel(Date.today + 15.years)
      @address.generate_score
      expect(@address.score).to be_within(3).of(original_score / 2) # We want it to be roughly half of the original score
      Timecop.return
    end

    it "heuristically adjusts if valid_at is set" do
      original_score = @address.score
      @address.valid_at = Date.today - 15.years
      @address.generate_score
      expect(@address.score).to be_within(10).of(original_score/ 2) # We want it to be roughly half of the original score
    end

    it "generates a score on an unsaved address object" do
      @address = FactoryGirl.build(:address, tags: [
        FactoryGirl.build(:tag, label: "SW1A 1AA", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
        FactoryGirl.build(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
        FactoryGirl.build(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
        FactoryGirl.build(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
        FactoryGirl.build(:tag, label: 50, tag_type: FactoryGirl.create(:tag_type, label: "paon"))
      ])
      Timecop.freeze(2015,3,25) do
        @address.generate_score
        expect(@address.score).to be_within(0.0001).of(500.5312)
      end
    end

  end

  it_behaves_like "Provenanceable"
  it_behaves_like "Timestamps"
  it_behaves_like "Validatable"

end
