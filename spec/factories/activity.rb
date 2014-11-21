FactoryGirl.define do

  factory :activity do
    executed_at { DateTime.now }
    derivations {
      [
        FactoryGirl.create(:derivation)
      ]
    }
  end

end
