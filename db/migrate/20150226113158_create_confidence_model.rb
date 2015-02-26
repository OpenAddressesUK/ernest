class CreateConfidenceModel < ActiveRecord::Migration
  def change
    create_table :confidences, :options => 'ENGINE=MyISAM' do |t|
      t.timestamps
      t.float :value
      t.references :left
      t.references :right
    end
  end
end
