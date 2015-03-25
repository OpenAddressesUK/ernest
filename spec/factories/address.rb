FactoryGirl.define do

  factory :address do
    tags { [
      FactoryGirl.create(:tag, label: "ABC 123", tag_type: FactoryGirl.create(:tag_type, label: "postcode")),
      FactoryGirl.create(:tag, label: "The Shire", tag_type: FactoryGirl.create(:tag_type, label: "town"), point: "POINT (309250 411754)"),
      FactoryGirl.create(:tag, label: "Hobbitton", tag_type: FactoryGirl.create(:tag_type, label: "locality")),
      FactoryGirl.create(:tag, label: "Hobbit Drive", tag_type: FactoryGirl.create(:tag_type, label: "street")),
      FactoryGirl.create(:tag, label: "3", tag_type: FactoryGirl.create(:tag_type, label: "paon"))
    ] }
    activity { FactoryGirl.create(:activity) }
    valid_at { DateTime.parse("2015-01-01") }
  end

end
