class AddAttributesToActivity < ActiveRecord::Migration
  def change
    add_column(:activities, :processing_script, :string)
  end
end
