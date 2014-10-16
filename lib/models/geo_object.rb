class GeoObject < ActiveRecord::Base
  has_many :dependents, :class_name => "GeoObject", :foreign_key => "dependent_id"
  belongs_to :tag

  before_create :set_defaults

  private

    def set_defaults
      self.point ||= "POINT (0 0)"
      self.line ||= "LINESTRING (0 0,0 10)"
      self.area ||= "POLYGON ((0 1,2 1,2 2,1 2,0 1))"
    end
end
