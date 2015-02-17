FactoryGirl.define do

  factory :source do
    input "http://example.com"
    activity { FactoryGirl.create(:activity, derivations: []) }
  end

end
