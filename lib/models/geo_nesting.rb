class GeoNesting < ActiveRecord::Base
  belongs_to :containee, class_name: "GeoObject"
  belongs_to :container, class_name: "GeoObject"
end
