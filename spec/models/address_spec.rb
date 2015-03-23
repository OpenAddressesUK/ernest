require 'spec_helper'

describe Address do

  it "should create a basic address" do
    address = FactoryGirl.create(:address)

    expect(address.tags.count).to eq(5)
    expect(address.postcode.label).to eq('ABC 123')
    expect(address.town.label).to eq('The Shire')
    expect(address.locality.label).to eq('Hobbitton')
    expect(address.street.label).to eq('Hobbit Drive')
    expect(address.paon.label).to eq('3')
  end

  it "creates a score" do
    address = FactoryGirl.create(:address)

    expect(address.score).to_not be_nil
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

    it "creates the correct score" do
      expect(@address.score).to be_within(0.0001).of(503.9596)
    end

    it "heuristically adjusts" do
      Timecop.travel(Date.today + 15.years)
      @address.generate_score
      expect(@address.score).to be_within(2).of(503.9596 / 2) # We want it to be roughly half of the original score
    end

  end

  it_behaves_like "Provenanceable"
  it_behaves_like "Timestamps"
  it_behaves_like "Validatable"

end
