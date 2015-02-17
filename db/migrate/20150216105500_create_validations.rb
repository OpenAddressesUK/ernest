class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations, :options => 'ENGINE=MyISAM' do |t|
      t.float :value
      t.integer :activity_id
    end
  end
end
