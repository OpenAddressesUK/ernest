class Address < ActiveRecord::Base
  has_and_belongs_to_many :tags

  TagType::ALLOWED_LABELS.each do |label|
    define_method(label) do
      tags.select { |g| g.tag_type.label == label }.first
    end
  end

end
