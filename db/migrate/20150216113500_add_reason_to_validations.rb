class AddReasonToValidations < ActiveRecord::Migration
  def change
    add_column :validations, :reason, :string
  end
end
