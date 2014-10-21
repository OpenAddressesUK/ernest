FactoryGirl.define do

  factory :source do
    url "http://example.com"
    activity { FactoryGirl.create(:activity) }
  end

end
