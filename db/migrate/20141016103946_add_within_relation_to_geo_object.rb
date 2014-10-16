class AddWithinRelationToGeoObject < ActiveRecord::Migration
  def change
    remove_column :geo_objects, :dependent_id

    create_table :geo_nestings, id: false do |t|
      t.integer :container_id
      t.integer :containee_id
    end
  end
end
