class CreateActivities < ActiveRecord::Migration
  def change
    
    create_table :activities, :options => 'ENGINE=MyISAM' do |t|
      t.datetime :executed_at
    end
    
    create_table :derivations, :options => 'ENGINE=MyISAM' do |t|
      t.integer :entity_id      
      t.string  :entity_type
      t.integer :activity_id
    end

    create_table :sources, :options => 'ENGINE=MyISAM' do |t|
      t.string  :url
      t.integer :activity_id
    end

    # Add activity to all existing entities
    add_column :addresses, :activity_id, :integer
    add_column :tags, :activity_id, :integer
    
  end
end
