class AddAttributionToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :attribution, :string
  end
end
