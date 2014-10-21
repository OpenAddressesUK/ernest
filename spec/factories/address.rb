FactoryGirl.define do

  factory :address do
    tags { [
      FactoryGirl.create(:tag, label: "ABC 123", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
      FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "post_town")),
      FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
      FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
      FactoryGirl.create(:tag, label: "3", tag_type: FactoryGirl.create(:tag_type, label: "building_no"))
    ] }
    activity { FactoryGirl.create(:activity) }
  end

end
