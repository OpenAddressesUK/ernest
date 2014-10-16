class Address < ActiveRecord::Base
  has_and_belongs_to_many :geo_objects

  Tag::ALLOWED_LABELS.each do |label|
    define_method(label) do
      geo_objects.select { |g| g.tag.label == label }.first
    end
  end

end
