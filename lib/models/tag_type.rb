class TagType < ActiveRecord::Base

  ALLOWED_LABELS = [
    'uprn',
    'saon',
    'paon',
    'street',
    'locality',
    'town',
    'postcode',
    'country'
  ]

  validates :label, inclusion: { in: ALLOWED_LABELS, message: "%{value} is not a valid label"  }

end
