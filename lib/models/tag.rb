class Tag < ActiveRecord::Base

  ALLOWED_LABELS = [
    'organisation',
    'department',
    'po_box',
    'sub_building_name',
    'sub_building_no',
    'building_name',
    'building_no',
    'dependent_street',
    'street',
    'double_dependent_locality',
    'dependent_locality',
    'locality',
    'post_town',
    'county',
    'postcode',
    'country'
  ]

  validates :label, inclusion: { in: ALLOWED_LABELS, message: "%{value} is not a valid label"  }

end
