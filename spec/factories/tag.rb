FactoryGirl.define do

  factory :tag do
    label "Foo Street"
    tag_type { FactoryGirl.create(:tag_type) }
    activity { FactoryGirl.create(:activity) }
  end

end
