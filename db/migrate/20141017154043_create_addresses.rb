class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses

    create_table :tags, :options => 'ENGINE=MyISAM' do |t|
      t.string :label
      t.column :point, :point, :null => false
      t.column :line, :line_string, :null => false
      t.column :area, :geometry, :null => false
      t.integer :tag_type_id
    end

    create_table :tag_types do |t|
      t.string :label
      t.string :description
    end

    create_table :addresses_tags, id: false do |t|
      t.belongs_to :address
      t.belongs_to :tag
    end

    add_index :tags, :point, :spatial => true
    add_index :tags, :line, :spatial => true
    add_index :tags, :area, :spatial => true

  end
end
