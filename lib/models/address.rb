class Address < ActiveRecord::Base

  include Provenanceable
  include Validatable

  has_and_belongs_to_many :tags
  belongs_to :user

  after_create :generate_score

  TagType::ALLOWED_LABELS.each do |label|
    define_method(label) do
      tags.select { |g| g.tag_type.label == label }.first
    end
  end

  def generate_score
    town_score = Confidence.create(left: postcode, right: town)
    street_score = Confidence.create(left: postcode, right: street)
    # Get total confidence
    confidence = (823.4 * street_score.value) + (176.6 * town_score.value)
    # Apply heuristic adjustment
    adjusted_score = confidence
    # Apply source adjustment
    self.score = adjusted_score * 0.61
  end
end
