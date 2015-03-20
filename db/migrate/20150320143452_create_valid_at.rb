class CreateValidAt < ActiveRecord::Migration
  def change
    add_column(:addresses, :valid_at, :datetime)
  end
end
