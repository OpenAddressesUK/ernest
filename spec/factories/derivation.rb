FactoryGirl.define do

  factory :derivation do
    entity { FactoryGirl.create(:source) }
  end

end
