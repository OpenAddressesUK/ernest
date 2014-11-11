require 'spec_helper'

describe Derivation do

  it "sets the correct entity type" do
    [
      :address,
      :tag,
      :source
    ].each do |type|
      derivation = FactoryGirl.create(:derivation, entity: FactoryGirl.create(type))
      expect(derivation.entity_type).to eq(type.to_s.classify)
    end
  end

  it_behaves_like "Timestamps"

end
