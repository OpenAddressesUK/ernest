class AddIndexesToDerivations < ActiveRecord::Migration
  def change
    add_index :derivations, :activity_id
  end
end
