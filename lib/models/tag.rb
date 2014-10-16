class Tag < ActiveRecord::Base
  ALLOWED_LABELS = [
    'pao','street','locality','town','postcode'
  ]

  validates :label, inclusion: { in: ALLOWED_LABELS, message: "%{value} is not a valid label"  }

end
