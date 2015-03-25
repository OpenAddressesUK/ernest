class AddScoreToAddresses < ActiveRecord::Migration
  def change
    add_column(:addresses, :score, :float)
  end
end
