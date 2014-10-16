class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses

    create_table :geo_objects, :options => 'ENGINE=MyISAM' do |t|
      t.string :label
      t.column :point, :point, :null => false
      t.column :line, :line_string, :null => false
      t.column :area, :geometry, :null => false
      t.integer :dependent_id
      t.integer :tag_id
    end

    create_table :tags do |t|
      t.string :label
      t.string :description
    end

    create_table :addresses_geo_objects, id: false do |t|
      t.belongs_to :address
      t.belongs_to :geo_object
    end

    add_index :geo_objects, :point, :spatial => true
    add_index :geo_objects, :line, :spatial => true
    add_index :geo_objects, :area, :spatial => true

  end
end
