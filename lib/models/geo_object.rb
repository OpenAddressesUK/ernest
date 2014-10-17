class GeoObject < ActiveRecord::Base
  belongs_to :tag

  has_many :containers, foreign_key: 'container_id', class_name: "GeoNesting"
  has_many :containees, foreign_key: 'containee_id', class_name: "GeoNesting"

  has_many :contains, through: :containers, source: 'containee'
  has_many :contained_by, through: :containees, source: 'container'

  # We can't have null spatial columns
  before_create :set_defaults

  private

    def set_defaults
      self.point ||= "POINT (0 0)"
      self.line ||= "LINESTRING (0 0,0 10)"
      self.area ||= "POLYGON ((0 1,2 1,2 2,1 2,0 1))"
    end
end
