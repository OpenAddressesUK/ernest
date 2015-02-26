class CreateConfidenceModel < ActiveRecord::Migration
  create_table :confidences, :options => 'ENGINE=MyISAM' do |t|
    t.timestamps
    t.float :value
  end
end
